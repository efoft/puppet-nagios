#
class nagios::client::checks::linux {

  if $nagios::client::defaultchecks {

    # Load
    if $nagios::client::load {
      if $::processorcount > 16 {
        $load_args = '-w 60,40,40 -c 90,70,70'
      } elsif $::processorcount > 8 {
        $load_args = '-w 25,20,20 -c 40,35,35'
      } elsif $::processorcount > 4 {
        $load_args = '-w 20,15,15 -c 35,30,30'
      } else {
        $load_args = '-w 15,10,10 -c 30,25,25'
      }
      nagios::client::nrpe_check { 'load':
        local_cmd_args => "-r ${load_args}",
      }
    }

    # Swap
    if $nagios::client::swap {
      nagios::client::nrpe_check { 'swap':
        local_cmd_args => "-w 20 -c 10",
        description    => 'Swap usage',
      }
    }

    # Procs
    if $nagios::client::procs {
      nagios::client::nrpe_check { 'procs':
        local_cmd_args => "-w 600 -c 700",
        description    => 'Total processes',
      }
    }

    # NTP
    if $nagios::client::ntp {
      nagios::client::nrpe_check { 'ntp':
        local_cmd      => 'check_ntp_time',
        local_cmd_args => "-4 -H ${nagios::params::check_ntp_remote_addr}",
        description    => 'NTP time',
      }
    }

    # Partitions
    if $nagios::client::partitions {
      nagios::plugin { 'disk': }
      nagios::client::nrpe_command { 'disk':
        args => '-w 80 -c 90 -p $ARG1$',
      }
      create_resources(nagios::client::partition, $::partitions)
    }

    # Linux RAID (mdadm)
    # based on custom fact
    if $nagios::client::linux_raid and $::mdstat_has_devices {
      nagios::client::nrpe_check { 'linux_raid':
        plugin_source => 'script',
        dep_packages  => ['nagios-plugins-perl'],
        description   => 'Linux RAID',
      }
    }

    # DRBD
    # based on custom fact
    if $nagios::client::drbd and $::drbd_used {
      nagios::client::nrpe_check { 'drbd':
        plugin_source => 'script',
      }
    }

    # Sensors
    if $nagios::client::sensors and ! $::is_virtual {
      nagios::client::nrpe_check { 'sensors': }
    }

    # IDE Smart
    if $nagios::client::ide_smart and ! $::is_virtual {
      nagios::plugin { 'ide_smart': }
      nagios::client::nrpe_command { 'ide_smart':
        args => '-d $ARG1$',
      }
      create_resources(nagios::client::disk, $::disks)
    }

    # Updates
    if $nagios::client::updates {
      nagios::client::nrpe_check { 'updates':
        package_name   => 'nagios-plugins-check-updates',
        local_cmd_args => '--security-only -t 30',
        description    => 'System Up-to-date',
      }
    }

    # SSH
    if $nagios::client::ssh {
      nagios::client::network_check { 'ssh': }
    }
  } # end of defaultchecks

  # Bacula
  if $nagios::client::bacula {
    if versioncmp($::operatingsystemmajrelease, '7') < 0 {
      notify { 'Bacula plugin is not available on OS version below 7. Skipping': loglevel => 'warning' }
    }
    else {
      if ! $nagios::client::bacula_pass {
        fail('Parameter bacula_pass is required for bacula monitoring.')
      }

      nagios::plugin { 'bacula': }
      nagios::client::nrpe_command { 'bacula':
        args    => '-H localhost -D $ARG1$ -M bacula-mon -K $ARG2$',
      }
      nagios::client::service { 'bacula_dir':
        command     => 'check_nrpe_bacula',
        args        => "!dir!${nagios::client::bacula_pass}",
        description => 'Bacula Director',
      }
      nagios::client::service { 'bacula_sd':
        command     => 'check_nrpe_bacula',
        args        => "!sd!${nagios::client::bacula_pass}",
        description => 'Bacula Storage',
      }
      nagios::client::service { 'bacula_fd':
        command     => 'check_nrpe_bacula',
        args        => "!fd!${nagios::client::bacula_pass}",
        description => 'Bacula File Daemon',
      }
    }
  }

  # MySQL
  if $nagios::client::mysql_local or $nagios::client::mysql_remote {

    $mysql_repl     = $nagios::client::mysql_repl
    $mysql_user     = $nagios::client::mysql_user
    $mysql_pass     = $nagios::client::mysql_pass

    # In Puppet 4 empty string is not falsey as in Puppet 3
    # So we check it mapped to boolean (for undef) and for emptyness
    if ! $mysql_user or empty($mysql_user) {
      fail('Parameter mysql_user is required')
    }
    if ! $mysql_pass or empty($mysql_pass) {
      fail('Parameter mysql_pass is required')
    }
  }

  if $nagios::client::mysql_local {
    nagios::client::nrpe_check { 'mysql':
      local_cmd_args => $mysql_repl ?
        { true  => "-s ${nagios::params::mysql_socket_path} -u \$ARG1$ -p \$ARG2$ -S",
          false => "-s ${nagios::params::mysql_socket_path} -u \$ARG1$ -p \$ARG2$"
        },
      nrpe_cmd_args => "!${mysql_user}!${mysql_pass}",
      description   => $mysql_repl ? { true => 'MySQL with replication via socket', false => "MySQL via socket" },
    }
  }

  if $nagios::client::mysql_remote {
    nagios::client::network_check { 'mysql':
      command     => $mysql_repl ? { true  => 'check_mysql_repl', false => 'check_mysql' },
      args        => "!${mysql_user}!${mysql_pass}",
      description => $mysql_repl ? { true => 'MySQL with replication via network', false => "MySQL via network" },
    }
  }

  # PostgreSQL
  $pgsql_user = $nagios::client::pgsql_user
  $pgsql_pass = $nagios::client::pgsql_pass

  if $nagios::client::pgsql_local {
    nagios::client::nrpe_check { 'pgsql':
      local_cmd_args => $pgsql_pass ? { undef => "-l ${pgsql_user}", default => "-l ${pgsql_user} -p ${pgsql_pass}" },
      description    => 'PostgreSQL via socket',
    }
  }

  if $nagios::client::pgsql_remote {
    nagios::client::network_check { 'pgsql':
      args        => $pgsql_pass ? { undef     => "!${pgsql_user}", default => "!${pgsql_user}!-p ${pgsql_pass}" },
      description => 'PostgreSQL via network',
    }
  }

  # MongoDB
  if $nagios::client::mongo_local {
    nagios::client::nrpe_check { 'mongodb':
      plugin_source => 'script',
      dep_packages  => ['python-pymongo'],
      description   => 'MongoDB via socket',
    }
  }

  if $nagios::client::mongo_remote {
    nagios::client::network_check { 'mongodb':
      plugin_source => 'script',
      dep_packages  => ['python-pymongo'],
      description => 'MongoDB via network',
    }
  }
}
