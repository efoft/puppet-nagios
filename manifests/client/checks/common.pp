#
class nagios::client::checks::common inherits ::nagios::client {

  # SMTP
  if $smtp {
    nagios::client::network_check { 'smtp': }
  }

  # IMAP & POP3
  if $imap {
    nagios::client::network_check { 'imap':
     package_name => 'nagios-plugins-tcp',
    }
  }
  if $pop {
    nagios::client::network_check { 'pop':
     package_name => 'nagios-plugins-tcp',
    }
  }

  # HTTP
  if $http {
    nagios::client::network_check { 'http': }
  }

  # SIP
  if $sip {
    if ! $sip_uri or empty($sip_uri) {
      fail('Parameter sip_uri is required')
    }

    nagios::client::network_check { 'sip':
      plugin_src   => 'script',
      dep_packages => ['nagios-plugins-perl','perl-Switch'],
      svc_cmd_args => "!${sip_uri}",
    }
  }
}
