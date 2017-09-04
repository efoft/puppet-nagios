# === Class nagios::server::selinux
#
class nagios::server::selinux(
  $selinux_package  = $nagios::params::selinux_package
) inherits ::nagios::server {

  package { $selinux_package:
    ensure => $::nagios::server::install::package_ensure
  }
}
