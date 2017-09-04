#
class nagios::client::checks::common {

  # SMTP
  if $nagios::client::smtp {
    nagios::client::network_check { 'smtp': }
  }

  # IMAP & POP3
  if $nagios::client::imap {
    nagios::client::network_check { 'imap':
     package_name => 'nagios-plugins-tcp',
    }
  }
  if $nagios::client::pop {
    nagios::client::network_check { 'pop':
     package_name => 'nagios-plugins-tcp',
    }
  }

  # HTTP
  if $nagios::client::http {
    nagios::client::network_check { 'http': }
  }

  # SIP
  if $nagios::client::sip {
    nagios::client::network_check { 'sip':
      plugin_source => 'script',
      dep_packages  => ['nagios-plugins-perl','perl-Switch'],
      args          => "!${nagios::client::sip_uri}",
    }
  }
}
