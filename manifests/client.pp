# === Class nagios::client
#
class nagios::client(
  Enum['present','absent'] $ensure    = 'present',
  Array[String] $servers              = ['127.0.0.1'],
  String $myip                        = $::ipaddress,
  Hash $contacts                      = {},
  String $nrpe_listen_port            = $nagios::params::nrpe_listen_port,
  Optional[String] $nrpe_bind_address = $nagios::params::nrpe_bind_address,
  Boolean $nrpe_allow_args            = $nagios::params::nrpe_allow_args,
  Boolean $nrpe_debug                 = $nagios::params::nrpe_debug,
  Boolean $defaultchecks              = true,
  # below are defaultchecks, can be disabled here individually
  ## linux
  Boolean $load                       = true,
  Boolean $swap                       = true,
  Boolean $procs                      = true,
  Boolean $ntp                        = true,
  Boolean $partitions                 = true,
  Boolean $linux_raid                 = true,
  Boolean $drbd                       = true,
  Boolean $sensors                    = true,
  Boolean $ide_smart                  = true,
  Boolean $updates                    = true,
  Boolean $ssh                        = true,
  ## end of linux defaultchecks
  ## windows
  Boolean $win_cpu                    = true,
  Boolean $win_memory                 = true,
  Boolean $win_network                = true,
  Boolean $win_diskspace              = true,
  Boolean $win_eventlog               = true,
  Array[String] $win_eventlog_files   = ['system','application'],
  ## end of windows defaultchecks
  ## common checks
  Boolean $smtp                       = false,
  Boolean $imap                       = false,
  Boolean $pop                        = false,
  Boolean $http                       = false,
  Boolean $bacula                     = false,
  Optional[String] $bacula_pass       = undef,
  ## end of common checks
  ## specific linux checks
  Boolean $mysql_local                = false,
  Boolean $mysql_remote               = false,
  Boolean $mysql_repl                 = false,
  String $mysql_user                  = 'nagios',
  Optional[String] $mysql_pass        = undef,
  Boolean $pgsql_local                = false,
  Boolean $pgsql_remote               = false,
  String $pgsql_user                  = 'nagios',
  Optional[String] $pgsql_pass        = undef,
  Boolean $mongo_local                = false,
  Boolean $mongo_remote               = false,
  ## end of specific linux checks
  ## specific windows checks
  Array $win_services                 = [],
  Boolean $mssql_remote               = false,
  String $mssql_user                  = 'nagios',
  Optional[String] $mssql_pass        = undef,
) inherits ::nagios::params {

  tag $servers

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

  # Form a list of host contacts. If it's empty - use 'nagiosadmin' instead. If `contacts` parameter is used in host declaration, it must have
  # a value otherwise it leaves this parameter in nagios cfg empty which leads to error. Nagiosadmin is always in contact anyway since it's in
  # admin contactgroup.
  $contacts_list = inline_template("<% if @contacts %><%= @contacts.select {|key,value| !value.to_s.match(/absent/) }.keys.join(',') %><% end %>")
  $host_contacts = empty($contacts_list) ? { true => 'nagiosadmin', false => $contacts_list }

  # exported resources
  @@nagios_host { $::fqdn:
    ensure   => $ensure,
    alias    => $::hostname,
    address  => $myip,
    use      => $::kernel ? { 'Linux' => 'linux-server', 'Windows' => 'windows-server' },
    contacts => $host_contacts,
  }

  if $contacts {
    create_resources(::nagios::admin, $contacts)
  }

  if $ensure == 'present' {
    include "::nagios::client::checks::${::kernel}"
    include ::nagios::client::checks::common
  }
}
