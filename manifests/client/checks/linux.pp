#
class nagios::client::checks::linux inherits ::nagios::client {

  if $defaultchecks {

    # Load
    if $load {
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
        clnt_cmd_args => "-r ${load_args}",
      }
    }

    # Swap
    if $swap {
      nagios::client::nrpe_check { 'swap':
        clnt_cmd_args => '-w 20% -c 10%',
        description   => 'Swap usage',
      }
    }

    # Procs
    if $procs {
      nagios::client::nrpe_check { 'procs':
        clnt_cmd_args => "-w 600 -c 700",
        description   => 'Total processes',
      }
    }

    # NTP
    if $ntp {
      nagios::client::nrpe_check { 'ntp':
        clnt_cmd_exec => 'check_ntp_time',
        clnt_cmd_args => "-4 -H ${check_ntp_remote_addr}",
        description   => 'NTP time',
      }
    }

    # Partitions
    if $partitions {
      nagios::client::nrpe_check { 'disk':
        clnt_cmd_args => '-w 10% -c 5% -w 100 -c 50 -p $ARG1$',
        manage_svc    => false,
      }

      $::partitions.each |$dev, $opts| {
        $mount = $opts['mount']
        if $mount != undef and $mount != 'swap' {
          nagios::client::service { $mount:
            command     => "check_nrpe_args!check_disk!${mount}",
            description => "Usage for ${mount}",
          }
        }
      }
    }

    # Linux RAID (mdadm)
    # based on custom fact
    if $linux_raid and $::mdstat_has_devices {
      nagios::client::nrpe_check { 'linux_raid':
        plugin_src   => 'script',
        dep_packages => ['nagios-plugins-perl'],
        description  => 'Linux RAID',
      }
    }

    # DRBD
    # based on custom fact
    if $drbd and $::drbd_used {
      nagios::client::nrpe_check { 'drbd':
        plugin_src => 'script',
      }
    }

    # Sensors
    if $sensors and ! $::is_virtual {
      nagios::client::nrpe_check { 'sensors': }
    }

    # IDE Smart
    if $smart and ! $::is_virtual {
      if $smart_type == 'ide' {
        nagios::client::nrpe_check { 'smart':
          plugin_src    => 'package',
          package_name  => 'nagios-plugins-ide_smart',
          clnt_cmd_exec => 'check_ide_smart',
          clnt_cmd_args => '-d $ARG1$',
          manage_svc    => false,
        }
      }
      elsif $smart_type == 'scsi' {
        nagios::client::nrpe_check { 'smart':
          plugin_src    => 'script',
          script_name   => 'check_smart.pl',
          dep_packages  => ['nagios-plugins-perl','smartmontools'],
          clnt_cmd_exec => 'check_smart.pl',
          clnt_cmd_args => '-d $ARG1$ -i scsi',
          manage_svc    => false,
        }
      }
      else {
        fail("Disk type ${smart_type} for SMART monitoring is not supported")
      }
      $::disks.each |$disk, $opts| {
        if $disk =~ /^(sd|vd|hd)/ and $opts['size_bytes'] != 0 {
          nagios::client::service { $disk:
            command     => "check_nrpe_args!check_smart!/dev/${disk}",
            description => "SMART for /dev/${disk}",
          }
        }
      }
    }

    # Updates
    if $updates {
      nagios::client::nrpe_check { 'updates':
        package_name  => 'nagios-plugins-check-updates',
        clnt_cmd_args => '--security-only -t 60',
        description   => 'System Up-to-date',
      }
    }

    # SSH
    if $ssh {
      nagios::client::network_check { 'ssh': }
    }
  } # end of defaultchecks

  # Bacula
  if $bacula {
    if versioncmp($::operatingsystemmajrelease, '7') < 0 {
      notify { 'Bacula plugin is not available on OS version below 7. Skipping': loglevel => 'warning' }
    }
    else {
      if ! $bacula_pass {
        fail('Parameter bacula_pass is required for bacula monitoring.')
      }

      nagios::client::nrpe_check { 'bacula':
        clnt_cmd_args => "-H localhost -D \$ARG1$ -M bacula-mon -K ${bacula_pass}",
        manage_svc    => false,
      }
      nagios::client::service { 'bacula_dir':
        command     => 'check_nrpe_args',
        args        => "!check_bacula!dir",
        description => 'Bacula Director',
      }
      nagios::client::service { 'bacula_sd':
        command     => 'check_nrpe_args',
        args        => "!check_bacula!sd",
        description => 'Bacula Storage',
      }
      nagios::client::service { 'bacula_fd':
        command     => 'check_nrpe_args',
        args        => "!check_bacula!fd",
        description => 'Bacula File Daemon',
      }
    }
  }

  # MySQL
  if $mysql_local or $mysql_remote {

    # In Puppet 4 empty string is not falsey as in Puppet 3
    # So we check it mapped to boolean (for undef) and for emptyness
    if ! $mysql_user or empty($mysql_user) {
      fail('Parameter mysql_user is required')
    }
    if ! $mysql_pass or empty($mysql_pass) {
      fail('Parameter mysql_pass is required')
    }
  }

  if $mysql_local {
    nagios::client::nrpe_check { 'mysql':
      clnt_cmd_args => $mysql_repl ?
        {
          true  => "-s ${mysql_socket_path} -u ${mysql_user} -p ${mysql_pass} -S",
          false => "-s ${mysql_socket_path} -u ${mysql_user} -p ${mysql_pass}"
        },
      description   => $mysql_repl ? { true            => 'MySQL with replication via socket', false => "MySQL via socket" },
    }
  }

  if $mysql_remote {
    nagios::client::network_check { 'mysql':
      svc_cmd      => $mysql_repl ? { true            => 'check_mysql_repl', false                   => 'check_mysql' },
      svc_cmd_args => "!${mysql_user}!${mysql_pass}",
      description  => $mysql_repl ? { true            => 'MySQL with replication via network', false => "MySQL via network" },
    }
  }

  # PostgreSQL
  if $pgsql_local {
    nagios::client::nrpe_check { 'pgsql':
      clnt_cmd_args => $pgsql_pass ? { undef => "-l ${pgsql_user}", default => "-l ${pgsql_user} -p ${pgsql_pass}" },
      description   => 'PostgreSQL via socket',
    }
  }

  if $pgsql_remote {
    nagios::client::network_check { 'pgsql':
      svc_cmd_args => $pgsql_pass ? { undef     => "!${pgsql_user}", default => "!${pgsql_user}!-p ${pgsql_pass}" },
      description  => 'PostgreSQL via network',
    }
  }

  # MongoDB
  if $mongo_local {
    nagios::client::nrpe_check { 'mongodb':
      plugin_src   => 'script',
      dep_packages => ['python-pymongo'],
      description  => 'MongoDB via socket',
    }
  }

  if $mongo_remote {
    nagios::client::network_check { 'mongodb':
      plugin_src   => 'script',
      dep_packages => ['python-pymongo'],
      description  => 'MongoDB via network',
    }
  }
}
