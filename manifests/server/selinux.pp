# === Class nagios::server::selinux
#
class nagios::server::selinux(
  $selinux_package  = $nagios::params::selinux_package
) inherits ::nagios::server {

  package { $selinux_package:
    ensure => $::nagios::server::install::package_ensure
  }

  ensure_resource('selboolean','daemons_enable_cluster_mode', {'value' => 'on', 'persistent' => true})
}
