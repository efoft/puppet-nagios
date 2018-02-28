# === Class nagios::server::commands
#
class nagios::server::commands(
  Integer $nrpe_exec_timeout     = 30,
  String $check_ntp_remote_addr  = $nagios::params::check_ntp_remote_addr,
  String $check_dns_resolve_name = $nagios::params::check_dns_resolve_name
) inherits ::nagios::params {

  # Taken from commands.cfg
  nagios_command { 'notify-host-by-email':
    command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\nHost: $HOSTNAME$\nState: $HOSTSTATE$\nAddress: $HOSTADDRESS$\nInfo: $HOSTOUTPUT$\n\nDate/Time: $LONGDATETIME$\n" | /bin/mail -s "** $NOTIFICATIONTYPE$ Host Alert: $HOSTNAME$ is $HOSTSTATE$ **" $CONTACTEMAIL$',
  }

  nagios_command { 'notify-service-by-email':
    command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\n\nService: $SERVICEDESC$\nHost: $HOSTALIAS$\nAddress: $HOSTADDRESS$\nState: $SERVICESTATE$\n\nDate/Time: $LONGDATETIME$\n\nAdditional Info:\n\n$SERVICEOUTPUT$" | /bin/mail -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTEMAIL$',
  }

  nagios_command { 'check_nrpe':
    command_line => "\$USER1$/check_nrpe -H \$HOSTADDRESS$ -t ${nrpe_exec_timeout} -c \$ARG1\$",
  }

  nagios_command { 'check_nrpe_args':
    command_line => "\$USER1$/check_nrpe -H \$HOSTADDRESS$ -t ${nrpe_exec_timeout} -c \$ARG1\$ -a \$ARG2$",
  }

  nagios_command { 'check_nrpe_nossl':
    command_line => "\$USER1$/check_nrpe -H \$HOSTADDRESS$ -t ${nrpe_exec_timeout} -n -c \$ARG1\$",
  }

  nagios_command { 'check_nrpe_args_nossl':
    command_line => "\$USER1$/check_nrpe -H \$HOSTADDRESS$ -t ${nrpe_exec_timeout} -n -c \$ARG1\$ -a \$ARG2$",
  }

  # Remote checks (via network)
  # All local checks ara done by nrpe
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
}
