# === Class nagios::server::config
#
class nagios::server::config {

  # Works great, but only if the "target" is the default (known limitation)
  resources { [
    'nagios_command',
    'nagios_contact',
    'nagios_contactgroup',
    'nagios_host',
    'nagios_hostgroup',
    'nagios_service',
    'nagios_servicegroup',
  ]:
    purge  => true,
  }

  if $::nagios::server::install::package_ensure == 'present' {
    nagios_hostgroup {
    'windows-servers': 
      alias => 'Windows hosts';
    'linux-servers':
      alias => 'Linux hosts';
    }

    contain ::nagios::server::commands
    contain ::nagios::server::contacts
    contain ::nagios::server::import
  }

  # must define since it's used later in other .pp
  $file_ensure = $nagios::server::install::package_ensure ? { 'purged' => 'absent', 'present' => 'present' }

  File {
    ensure => $file_ensure,
    owner  => 'root',
  }

  # must be resolved here since it's used in .erb
  $managed_cfg_files = $nagios::params::managed_cfg_files

  file { $nagios::params::nagios_cfg:
    content => template('nagios/nagios.cfg.erb'),
  }

  file { $managed_cfg_files:
    group   => 'nagios',
    mode    => '0640',
  }
}
