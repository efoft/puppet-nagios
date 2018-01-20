# === Class nagios::server::commands
#
class nagios::server::commands(
  $nrpe                   = '$USER1$/check_nrpe -H $HOSTADDRESS$ -t 30',
  $nrpe_nossl             = '$USER1$/check_nrpe -H $HOSTADDRESS$ -t 30 -n',
  $check_ntp_remote_addr  = $nagios::params::check_ntp_remote_addr,
  $check_dns_resolve_name = $nagios::params::check_dns_resolve_name
) inherits ::nagios::params {

  # Taken from commands.cfg
  nagios_command { 'notify-host-by-email':
    command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\nHost: $HOSTNAME$\nState: $HOSTSTATE$\nAddress: $HOSTADDRESS$\nInfo: $HOSTOUTPUT$\n\nDate/Time: $LONGDATETIME$\n" | /bin/mail -s "** $NOTIFICATIONTYPE$ Host Alert: $HOSTNAME$ is $HOSTSTATE$ **" $CONTACTEMAIL$',
  }

  nagios_command { 'notify-service-by-email':
    command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\n\nService: $SERVICEDESC$\nHost: $HOSTALIAS$\nAddress: $HOSTADDRESS$\nState: $SERVICESTATE$\n\nDate/Time: $LONGDATETIME$\n\nAdditional Info:\n\n$SERVICEOUTPUT$" | /bin/mail -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTEMAIL$',
  }

  nagios_command { 'check_nrpe':
    command_line => "${nrpe} -c \$ARG1\$",
  }

  # Remote checks (via network)
  # All local checks ara done by nrpe and produced from client's @@nagios_service
  nagios_command { 'check-host-alive':
    command_line => '$USER1$/check_ping -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 5',
  }

  nagios_command { 'check_ftp':
    command_line => '$USER1$/check_ftp -H $HOSTADDRESS$ $ARG1$',
  }

  nagios_command { 'check_hpjd':
    command_line => '$USER1$/check_hpjd -H $HOSTADDRESS$ $ARG1$',
  }

  nagios_command { 'check_snmp':
    command_line => '$USER1$/check_snmp -H $HOSTADDRESS$ $ARG1$',
  }

  nagios_command { 'check_http':
    command_line => '$USER1$/check_http -I $HOSTADDRESS$ $ARG1$',
  }

  nagios_command { 'check_ssh':
    command_line => '$USER1$/check_ssh $ARG1$ $HOSTADDRESS$',
  }

  nagios_command { 'check_dhcp':
    command_line => '$USER1$/check_dhcp $ARG1$',
  }

  nagios_command { 'check_ping':
    command_line => '$USER1$/check_ping -H $HOSTADDRESS$ $ARG1$',
  }

  nagios_command { 'check_ping6':
    command_line => '$USER1$/check_ping -6 $ARG1$',
  }

  nagios_command { 'check_pop':
    command_line => '$USER1$/check_pop -H $HOSTADDRESS$ $ARG1$',
  }

  nagios_command { 'check_imap':
    command_line => '$USER1$/check_imap -H $HOSTADDRESS$ $ARG1$',
  }

  nagios_command { 'check_smtp':
    command_line => '$USER1$/check_smtp -H $HOSTADDRESS$ $ARG1$',
  }

  nagios_command { 'check_tcp':
    command_line => '$USER1$/check_tcp -H $HOSTADDRESS$ -p $ARG1$ $ARG2$',
  }

  nagios_command { 'check_udp':
    command_line => '$USER1$/check_udp -H $HOSTADDRESS$ -p $ARG1$ $ARG2$',
  }

  nagios_command { 'check_nt':
    command_line => '$USER1$/check_nt -H $HOSTADDRESS$ -p 12489 -v $ARG1$ $ARG2$',
  }

  # MySQL
  # standalone
  nagios_command { 'check_mysql':
    command_line  => '$USER1$/check_mysql -H $HOSTADDRESS$ -u $ARG1$ -p $ARG2$',
  }
  # with replication
  nagios_command { 'check_mysql_repl':
    command_line  => '$USER1$/check_mysql -H $HOSTADDRESS$ -u $ARG1$ -p $ARG2$ -S',
  }

  # PostgreSQL
  nagios_command { 'check_pgsql':
    command_line  => '$USER1$/check_pgsql -H $HOSTADDRESS$ -l $ARG1$ $ARG2$',
  }

  # NTP
  # check offset of local clock and remote ntp
  nagios_command { 'check_ntp':
    command_line  => "\$USER1$/check_ntp_time -4 -H ${check_ntp_remote_addr} -t 60",
  }

  # DNS
  # check if we can resolve given name
  nagios_command { 'check_dns':
    command_line  => "\$USER1$/check_dns -H ${check_dns_resolve_name}",
  }

  ## Custom commands for remote checks
  # Mail
  nagios_command { 'check_simap':
    command_line  => '$USER1$/check_simap -H $HOSTADDRESS$ -p $ARG1$',
  }
  nagios_command { 'check_spop':
    command_line  => '$USER1$/check_spop -H $HOSTADDRESS$ -p $ARG1$',
  }

  # SIP
  nagios_command { 'check_sip':
    command_line  => '$USER1$/check_sip -u sip:$ARG1$ -H $HOSTADDRESS$ -p $ARG2$',
  }

  # check_nt with -s argument (for auth)
  nagios_command { 'check_nt_auth':
    command_line  => '$USER1$/check_nt -H $HOSTADDRESS$ -p 12489 -s $ARG1$ -v $ARG2$ $ARG3$',
  }

  # MSSQL
  nagios_command { 'check_mssql':
    command_line  => '$USER1$/check_mssql -H $HOSTADDRESS$ -p 1433 --username $ARG1$ --password $ARG2$',
  }

  # MongoDB
  nagios_command { 'check_mongodb':
    command_line  => '$USER1$/check_mongodb -H $HOSTADDRESS$',
  }

  # HTTP by URL
  nagios_command { 'check_http_url':
    command_line => '$USER1$/check_http -H $ARG1$ -p $ARG2$ $ARG3$',
  }

  # Proxy
  nagios_command { 'check_proxy':
    command_line => '$USER1$/check_tcp -H $HOSTADDRESS$ -p $ARG1$',
  }

  # Nginx
  nagios_command { 'check_nginx':
    command_line => '$USER1$/check_nginx $ARG1$',
  }

  ## Custom NRPE-based commands
  # === Linux hosts
  nagios_command { 'check_nrpe_users':
    command_line => "${nrpe} -c check_users",
  }
  nagios_command { 'check_nrpe_load':
    command_line => "${nrpe} -c check_load",
  }
  nagios_command { 'check_nrpe_zombie_procs':
    command_line => "${nrpe} -c check_zombie_procs",
  }
  nagios_command { 'check_nrpe_swap':
    command_line => "${nrpe} -c check_swap",
  }
  nagios_command { 'check_nrpe_disk':
    command_line => "${nrpe} -c check_disk -a \$ARG1\$",
  }
  nagios_command { 'check_nrpe_procs':
    command_line => "${nrpe} -c check_procs",
  }
  nagios_command { 'check_nrpe_ntp':
    command_line => "${nrpe} -u -c check_ntp_time",
  }
  nagios_command { 'check_nrpe_linux_raid':
    command_line => "${nrpe} -c check_linux_raid",
  }
  nagios_command { 'check_nrpe_drbd':
    command_line => "${nrpe} -c check_drbd",
  }
  nagios_command { 'check_nrpe_sensors':
    command_line => "${nrpe} -c check_sensors",
  }
  nagios_command { 'check_nrpe_ide_smart':
    command_line => "${nrpe} -c check_ide_smart -a \$ARG1$",
  }
  nagios_command { 'check_nrpe_updates':
    command_line => "${nrpe} -c check_updates",
  }
  nagios_command { 'check_nrpe_bacula':
    command_line => "${nrpe} -c check_bacula -a \$ARG1$ \$ARG2$",
  }
  nagios_command { 'check_nrpe_mysql':
    command_line => "${nrpe} -c check_mysql -a \$ARG1$ \$ARG2$",
  }
  nagios_command { 'check_nrpe_pgsql':
    command_line => "${nrpe} -c check_pgsql",
  }
  nagios_command { 'check_nrpe_mongodb':
    command_line => "${nrpe} -c check_mongodb",
  }
  # === Windows hosts
  nagios_command { 'check_nrpe_win_cpu':
    command_line => "${nrpe_nossl} -c check_cpu",
  }
  nagios_command { 'check_nrpe_win_memory':
    command_line => "${nrpe_nossl} -c check_memory",
  }
  nagios_command { 'check_nrpe_win_network':
    command_line => "${nrpe_nossl} -c check_network",
  }
  nagios_command { 'check_nrpe_win_diskspace':
    command_line => "${nrpe_nossl} -c alias_space",
  }
  nagios_command { 'check_nrpe_win_eventlog':
    command_line => "${nrpe_nossl} -c alias_eventlog",
  }
  nagios_command { 'check_nrpe_win_service':
    command_line => "${nrpe_nossl} -c check_service -a service=\$ARG1$",
  }
}
