# === Class nagios::server ===
# Installs and configures nagios server.
#
# === Parameters ===
# [*admin_email*]
#   Who receives all admin notifications.
#   Default: nagios@localhost
#
# [*admin_members*]
#   Http users who have admin rights.
#   Default: nagiosadmin
#
# [*webpass*]
#   Password string for web gui authentication.
#
class nagios::server(
  Enum['present','absent'] $ensure = 'present',
  String $admin_email              = $nagios::params::admin_email,
  Array[String] $admin_members     = $nagios::params::admin_members,
  String $webpass,
) inherits nagios::params {

  class { '::nagios::server::install': } ->
  class { '::nagios::server::selinux': } ->
  class { '::nagios::server::config':  } ~>
  class { '::nagios::server::service': }
}
