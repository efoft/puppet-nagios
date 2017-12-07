#
class nagios::server::config {

  assert_private('This is private class')

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
    notify => Service[$nagios::params::service_name],
  }

  if $nagios::server::ensure == 'present' {
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

  File {
    ensure => $nagios::server::ensure,
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
