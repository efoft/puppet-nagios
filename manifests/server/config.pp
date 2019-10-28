#
class nagios::server::config inherits nagios::server {

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
    notify => Service[$service_name],
  }

  if $ensure == 'present' {
    nagios_hostgroup {
    'windows-servers': 
      alias => 'Windows hosts';
    'linux-servers':
      alias => 'Linux hosts';
    }

    contain nagios::server::config::commands
    contain nagios::server::config::contacts
  }

  file { $nagios_cfg:
    ensure  => $ensure,
    owner   => 'root',
    content => template('nagios/nagios.cfg.erb'),
  }

  file { $managed_cfg_files:
    ensure => $ensure,
    owner  => 'root',
    group  => 'nagios',
    mode   => '0640',
  }
}
