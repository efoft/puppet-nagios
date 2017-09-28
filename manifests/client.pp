# === Class nagios::client
#
class nagios::client(
  $ensure             = true,
  $servers            = ['127.0.0.1'],
  $myip               = $::ipaddress,
  $contacts           = {},
  $nrpe_listen_port   = $nagios::params::nrpe_listen_port,
  $nrpe_bind_address  = $nagios::params::nrpe_bind_address,
  $nrpe_allow_args    = $nagios::params::nrpe_allow_args,
  $nrpe_debug         = $nagios::params::nrpe_debug,
  $nrpe_include_dir   = $nagios::params::nrpe_include_dir,
  $defaultchecks      = true,
  # below are defaultchecks, can be disabled here individually
  ## linux
  $load               = true,
  $swap               = true,
  $procs              = true,
  $ntp                = true,
  $partitions         = true,
  $linux_raid         = true,
  $drbd               = true,
  $sensors            = true,
  $ide_smart          = true,
  $updates            = true,
  $ssh                = true,
  ## end of linux defaultchecks
  ## windows
  $win_cpu            = true,
  $win_memory         = true,
  $win_network        = true,
  $win_diskspace      = true,
  $win_eventlog       = true,
  $win_eventlog_files = ['system','application'],
  ## end of windows defaultchecks
  ## common checks
  $smtp               = false,
  $imap               = false,
  $pop                = false,
  $http               = false,
  $bacula             = false,
  $bacula_pass        = undef,
  ## end of common checks
  ## specific linux checks
  $mysql_local        = false,
  $mysql_remote       = false,
  $mysql_repl         = false,
  $mysql_user         = 'nagios',
  $mysql_pass         = undef,
  $pgsql_local        = false,
  $pgsql_remote       = false,
  $pgsql_user         = 'nagios',
  $pgsql_pass         = undef,
  $mongo_local        = false,
  $mongo_remote       = false,
  ## end of specific linux checks
  ## specific windows checks
  $win_services       = [],
  $mssql_remote       = false,
  $mssql_user         = 'nagios',
  $mssql_pass         = undef,
) inherits ::nagios::params {

  $package_ensure = $ensure ? {
    true        => 'present',
    'installed' => 'present',
    false       => 'purged',
    'absent'    => 'purged',
    default     => $ensure
  }

  validate_re($package_ensure, ['present','purged'], "`package_ensure` got invalid value of `${package_ensure}`")

  # Install nrpe package
  package { $nagios::params::nrpe_package:
    ensure => $package_ensure,
  }

  # If SELinux in place, fix policy
  if $::kernel == 'linux' {
    package { 'nrpe-selinux':
      ensure => $package_ensure,
    }
  }

  $file_ensure = $package_ensure ? {
    'present' => 'present',
    'purged'  => 'absent',
  }

  # Main config
  file { $nagios::params::nrpe_cfg_file:
    ensure  => $file_ensure,
    content => template("nagios/${nrpe_cfg_template}"),
    notify  => Service[$nagios::params::nrpe_service],
    require => Package[$nagios::params::nrpe_package],
  }

  # Include dir
  file { $nrpe_include_dir:
    ensure  => $package_ensure ? { 'present' => 'directory', 'absent' => 'absent' },
    recurse => true,
    force   => true,
    purge   => true,
    require => Package[$nagios::params::nrpe_package],
  }

  $service_ensure = $package_ensure ? {
    'present' => 'running',
    'purged'  => 'stopped'
  }

  # Service
  service { $nagios::params::nrpe_service:
    ensure  => $service_ensure,
    enable  => $service_ensure ? { 'running' => true, default => false },
  }

  # Form a list of host contacts. If it's empty - use 'nagiosadmin' instead. If `contacts` parameter is used in host declaration, it must have
  # a value otherwise it leaves this parameter in nagios cfg empty which leads to error. Nagiosadmin is always in contact anyway since it's in
  # admin contactgroup.
  $contacts_list = inline_template("<% if @contacts %><%= @contacts.select {|key,value| !value.to_s.match(/absent/) }.keys.join(',') %><% end %>")
  $host_contacts = empty($contacts_list) ? { true => 'nagiosadmin', false => $contacts_list }

  # exported resources
  @@nagios_host { $::fqdn:
    ensure   => $file_ensure,
    alias    => $::hostname,
    address  => $myip,
    use      => $::kernel ? { 'Linux' => 'linux-server', 'Windows' => 'windows-server' },
    contacts => $host_contacts,
  }

  if $contacts {
    create_resources(::nagios::admin, $contacts)
  }

  if $file_ensure == 'present' {
    include "::nagios::client::checks::${::kernel}"
    include ::nagios::client::checks::common
  }
}
