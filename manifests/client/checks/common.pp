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
  if $imaps {
    nagios::client::network_check { 'imaps':
     package_name => 'nagios-plugins-tcp',
     svc_cmd      => 'check_imap',
     svc_cmd_args => '!-S -p 993',
    }
  }
  if $pop3 {
    nagios::client::network_check { 'pop3':
     package_name => 'nagios-plugins-tcp',
     svc_cmd      => 'check_pop',
    }
  }
  if $pop3s {
    nagios::client::network_check { 'pop3s':
     package_name => 'nagios-plugins-tcp',
     svc_cmd      => 'check_pop',
     svc_cmd_args => '!-S -p 995',
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
