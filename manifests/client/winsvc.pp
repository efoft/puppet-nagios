#
define nagios::client::winsvc {
  nagios::client::service { "win_service_${title}":
    command     => "check_nrpe_win_service!${title}",
    description => "Service ${title}",
  }
}
