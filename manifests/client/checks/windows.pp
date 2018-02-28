#
class nagios::client::checks::windows inherits ::nagios::client {

  if $defaultchecks {

    Nagios::Client::Service {
      command => 'check_nrpe_nossl',
    }

    # CPU
    if $win_cpu {
      nagios::client::service { 'win_cpu':
        args        => '!check_cpu',
        description => 'CPU usage',
      }
    }

    # Memory
    if $win_memory {
      nagios::client::service { 'win_memory':
        args        => '!check_memory',
        description => 'Memory usage',
      }
    }

    # Disks
    if $win_diskspace {
      nagios::client::service { 'win_diskspace':
        args        => '!alias_space',
        description => 'Disk space usage',
      }
    }

    # Eventlog
    if $win_eventlog {
      nagios::client::service { 'win_eventlog':
        args        => '!alias_eventlog',
        description => 'Event Log',
      }
    }
  } # end of defaultchecks

  # Win services
  if $win_services {
    $win_services.each |String $winsvc| {
      nagios::client::service { $winsvc:
        command     => 'check_nrpe_args_nossl',
        args        => "!check_service!service=\"${winsvc}\"",
        description => "Service ${winsvc}",
      }
    }
  }

  # MSSQL
  if $mssql_remote {
    nagios::client::network_check { 'mssql':
      plugin_src   => 'script',
      dep_packages => ['php-mssql'],
      svc_cmd_args => "!${mssql_user}!${mssql_pass}",
    }
  }
}
