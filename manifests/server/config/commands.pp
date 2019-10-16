#
class nagios::server::config::commands inherits nagios::server {

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

  ## No-SSL commands are also updated with -2 flag meaning version 2 nrpe protocol. No-SSL are used here
  ## only for Windows hosts which also don't support version 3.
  nagios_command { 'check_nrpe_nossl':
    command_line => "\$USER1$/check_nrpe -H \$HOSTADDRESS$ -t ${nrpe_exec_timeout} -2n -c \$ARG1\$",
  }

  nagios_command { 'check_nrpe_args_nossl':
    command_line => "\$USER1$/check_nrpe -H \$HOSTADDRESS$ -t ${nrpe_exec_timeout} -2n -c \$ARG1\$ -a \$ARG2$",
  }

  nagios_command { 'check-host-alive':
    command_line => '$USER1$/check_ping -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 5',
  }

  nagios_command { 'check_ping':
    command_line => '$USER1$/check_ping -H $HOSTADDRESS$ $ARG1$',
  }

  nagios_command { 'check_ping6':
    command_line => '$USER1$/check_ping -6 $ARG1$',
  }
}
