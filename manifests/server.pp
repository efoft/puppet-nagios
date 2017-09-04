# === Class nagios::server
#
#
class nagios::server(
  $ensure        = $nagios::params::package_ensure,
  $admin_email   = $nagios::params::admin_email,
  $admin_members = $nagios::params::admin_members,
  $webpass       = $nagios::params::webpass
) inherits ::nagios::params {

  class { '::nagios::server::install': } ->
  class { '::nagios::server::selinux': } ->
  class { '::nagios::server::config':  } ~>
  class { '::nagios::server::service': }
}
