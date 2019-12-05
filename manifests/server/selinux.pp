#
class nagios::server::selinux inherits nagios::server::install {

  assert_private('This is private class')

  package { $selinux_package:
    ensure => $ensure ? {'absent' => 'purged', default => $ensure},
  }

  ensure_resource('selboolean','daemons_enable_cluster_mode', {'value' => 'on', 'persistent' => true})
}
