# === Class nagios::server ===
# Installs and configures nagios server.
#
# Client hosts and their resources are exported to PuppetDB and than
# collected here.
#
# === Parameters ===
# [*site*]
#   Any name that must be common for nagios server and clients served by
#   this server. This value is used for tag filtering when collecting 
#   exported resources from clients.
#   Default: domain fact
#
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
# [*encryption*]
#   Password hashing algorithm for htpasswd. Can be `bcrypt` or `sha`.
#   bcrypt is only available with Apache 2.4. For Apache 2.2 and Nginx
#   sha should be selected.
#
class nagios::server(
  Enum['present','absent'] $ensure = 'present',
  String $site                     = $::domain,
  String $admin_email              = $nagios::params::admin_email,
  Array[String] $admin_members     = $nagios::params::admin_members,
  String $webpass,
  Enum['bcrypt','sha'] $encryption = $nagios::params::encryption,
) inherits nagios::params {

  class { '::nagios::server::install': } ->
  class { '::nagios::server::selinux': } ->
  class { '::nagios::server::config':  } ~>
  class { '::nagios::server::service': }
}
