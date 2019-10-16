#
class nagios::server::service inherits nagios::server {

  assert_private('This is private class')

  service { $service_name:
    ensure  => $ensure ? { 'present' => 'running', 'absent' => undef },
    enable  => $ensure ? { 'present' => true,      'absent' => undef },
  }
}
