# === Class nagios::client ===
# Installs and configures nagios client on Linux and Windows.
#
# === Parameters ===
# [*servers*]
#   From where nrpe allows connections from. Can be IP addresses or resolvable hostnames.
#   Can be single value or array.
#
# [*myip*]
#   IP reachable from nagios server.
#
# [*site*]
#   The value must be the same as for nagios server. This value is used for tagging exported resources.
#   Default: domain fact
#
# [*contacts*]
#   Optional. If not specified nagiosadmin is the only contact and administrator for this client host.
#   Format is like the following (hiera format):
#     admin1:
#        alias: 'Admin 1'
#        email: 'admin@example.com'
#        password: admin1
#     admin2:
#       alias: 'Nagios Admin'
#       email: 'nagios@localhost'
#       password: admin2
#   Once set they can log in into GUI and also they receive notification for the host they are specified as contacts.
#
# [*nrpe_listen_port*]
#   Default: 5666
#
# [*nrpe_bind_address*]
#   Address that nrpe should bind to in case there are more than one interface
#   and you do not want nrpe to bind on all interfaces.
#   If not set, 127.0.0.1 is used.
#   Default: undef
#
# [*nrpe_allow_args*]
#   Corresponds to nrpe.cfg dont_blame_nrpe parameter which allows arguments to be passed via nrpe_check.
#
# [*nrpe_debug*]
#   Corresponds to nrpe.cfg debug parameter.
#
# [*defaultchecks*]
#   Can be enabled or disabled at once for the client.
#   Each of these checks can be disabled or enabled also individually.
#
# [*ext_scripts*]
#   Use of nsclient++ external scripts mechanism that allows to call external programs on client and return
#   the result of their execution. We assume that executable itself is already in place.
#   Hash should look like this (hiera format):
#     ext_scripts:
#       intel_rst_raid:
#         command: "c:\\nagios\\check_intel_rst\\check_intel_rst.exe path=c:\\nagios\\check_intel_rst"
#         use: generic-service
#
# All the rest parameters are swithes to specific checks and some params for them (like passwords).
#
class nagios::client(
  Enum['present','absent'] $ensure       = 'present',
  Variant[Array[String],String] $servers,
  Stdlib::Compat::Ipv4 $myip             = $::ipaddress,
  String $site                           = $::domain,
  Hash $contacts                         = {},
  Numeric $nrpe_listen_port              = $nagios::params::nrpe_listen_port,
  Optional[String] $nrpe_bind_address    = $nagios::params::nrpe_bind_address,
  Boolean $nrpe_allow_args               = $nagios::params::nrpe_allow_args,
  Boolean $nrpe_debug                    = $nagios::params::nrpe_debug,
  Boolean $defaultchecks                 = true,
  # below are defaultchecks, can be disabled here individually
  ## linux
  Boolean $load                          = true,
  Boolean $swap                          = true,
  Boolean $procs                         = true,
  Boolean $ntp                           = true,
  Boolean $partitions                    = true,
  Boolean $linux_raid                    = true,
  Boolean $drbd                          = true,
  Boolean $sensors                       = true,
  Boolean $ide_smart                     = true,
  Boolean $updates                       = true,
  Boolean $ssh                           = true,
  ## end of linux defaultchecks
  ## windows
  Boolean $win_cpu                       = true,
  Boolean $win_memory                    = true,
  Boolean $win_diskspace                 = true,
  Boolean $win_eventlog                  = true,
  Array[String] $win_eventlog_files      = ['system','application'],
  ## end of windows defaultchecks
  ## common checks
  Boolean $smtp                          = false,
  Boolean $imap                          = false,
  Boolean $pop                           = false,
  Boolean $http                          = false,
  Boolean $bacula                        = false,
  Optional[String] $bacula_pass          = undef,
  ## end of common checks
  ## specific linux checks
  Boolean $mysql_local                   = false,
  Boolean $mysql_remote                  = false,
  Boolean $mysql_repl                    = false,
  String $mysql_user                     = 'nagios',
  Optional[String] $mysql_pass           = undef,
  Boolean $pgsql_local                   = false,
  Boolean $pgsql_remote                  = false,
  String $pgsql_user                     = 'nagios',
  Optional[String] $pgsql_pass           = undef,
  Boolean $mongo_local                   = false,
  Boolean $mongo_remote                  = false,
  ## end of specific linux checks
  ## specific windows checks
  Array $win_services                    = [],
  Boolean $mssql_remote                  = false,
  String $mssql_user                     = 'nagios',
  Optional[String] $mssql_pass           = undef,
  Hash $ext_scripts                      = {},
  ## end of specific windows checks
) inherits ::nagios::params {

  # Install nrpe package
  package { $nagios::params::nrpe_package:
    ensure => $ensure ? { 'present' => 'present', 'absent' => 'purged' },
  }

  # If SELinux in place, fix policy
  if $::kernel == 'linux' {
    package { 'nrpe-selinux':
      ensure => $ensure ? { 'present' => 'present', 'absent' => 'purged' },
    }
  }

  # Always allow to connect from localhost
  $_servers = unique(concat(['127.0.0.1'], $servers))

  # Main config
  file { $nagios::params::nrpe_cfg_file:
    ensure  => $ensure,
    content => template("nagios/${nagios::params::nrpe_cfg_template}"),
    notify  => Service[$nagios::params::nrpe_service],
    require => Package[$nagios::params::nrpe_package],
  }

  # Include dir
  if $nagios::params::nrpe_include_dir {
    file { $nagios::params::nrpe_include_dir:
      ensure  => $ensure ? { 'present' => 'directory', 'absent' => 'absent' },
      recurse => true,
      force   => true,
      purge   => true,
      require => Package[$nagios::params::nrpe_package],
    }
  }

  # Service
  service { $nagios::params::nrpe_service:
    ensure => $ensure ? { 'present' => 'running', 'absent' => undef },
    enable => $ensure ? { 'present' => true, 'absent'      => undef },
  }

  # If `contacts` parameter is used in host declaration, it must have
  # a value otherwise it leaves this parameter in nagios cfg empty which leads to error.
  # That's why we use nagiosadmin if nothing specified.
  # It contacts are supplied, nagiosadmin is not added but nagiosadmin is always a contact
  # since it's in admin contactgroup.
  $contacts_list = inline_template("<% if @contacts %><%= @contacts.select {|key,value| !value.to_s.match(/absent/) }.keys.join(',') %><% end %>")
  $host_contacts = empty($contacts_list) ? { true => 'nagiosadmin', false => $contacts_list }

  # exported resources
  tag $site

  @@nagios_host { $::fqdn:
    ensure   => $ensure,
    alias    => $::hostname,
    address  => $myip,
    use      => $::kernel ? { 'Linux' => 'linux-server', 'Windows' => 'windows-server' },
    contacts => $host_contacts,
  }

  if $ensure == 'present' {
    create_resources(::nagios::admin, $contacts)

    include "::nagios::client::checks::${::kernel}"
    include ::nagios::client::checks::common

    if $::kernel == 'Windows' and $ext_scripts {
      $ext_scripts.each |$k,$v| {
        nagios::client::service { $k:
          command     => 'check_nrpe',
          args        => "!${k}",
          use         => $v['use'],
          description => $v['description'],
        }
      }
    }
  }
}
