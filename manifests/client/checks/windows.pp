#
class nagios::client::checks::windows {

  if $nagios::client::defaultchecks {

    # CPU
    if $nagios::client::win_cpu {
      nagios::client::service { 'win_cpu':
        description => 'CPU usage',
      }
    }

    # Memory
    if $nagios::client::win_memory {
      nagios::client::service { 'win_memory':
        description => 'Memory usage',
      }
    }

    # Network
    if $nagios::client::win_network {
      nagios::client::service { 'win_network':
        description => 'Network interface',
      }
    }

    # Disks
    if $nagios::client::win_diskspace {
      nagios::client::service { 'win_diskspace':
        description => 'Disk space usage',
      }
    }

    # Eventlog
    if $nagios::client::win_eventlog {
      nagios::client::service { 'win_eventlog':
        description => 'Event Log',
      }
    }
  } # end of defaultchecks

  # Win services
  if $nagios::client::win_services {
    nagios::client::winsvc { $nagios::client::win_services: }
  }

  # MSSQL
  if $nagios::client::mssql_remote {

    $mssql_user = $nagios::client::mssql_user
    $mssql_pass = $nagios::client::mssql_pass

    nagios::client::network_check { 'mssql':
      plugin_source => 'script',
      dep_packages  => ['php-mssql'],
      args          => "!${mssql_user}!${mssql_pass}",
    }
  }
}
