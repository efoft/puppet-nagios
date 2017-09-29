#
class nagios::server::service {

  assert_private('This is private class')

  service { $nagios::params::service_name:
    ensure => $nagios::server::ensure ? { 'present' => 'running', 'absent' => undef },
    enable => $nagios::server::ensure ? { 'present' => true, 'absent'      => undef },
  }
}
