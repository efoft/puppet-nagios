# === Class nagios::server ===
# Installs and configures nagios server.
#
# @param admin_email
#   Who receives all admin notifications.
#
# @param admin_members
#   Http users who have admin rights.
#
# @param webpass
#   Password string for nagiosadmin web gui authentication.
#
# @param encryption
#   Encryption method used for GUI htpasswd. If skipped method will be auto-detected.
#
class nagios::server(
  Enum['present','absent']       $ensure        = 'present',
  String                         $admin_email   = 'nagiosadmin@localhost',
  Array[String[1]]               $admin_members = ['nagiosadmin'],
  String[1]                      $webpass,
  Optional[Enum['sha','bcrypt']] $encryption    = undef,
) inherits nagios::params {

  class { 'nagios::server::install': } ->
  class { 'nagios::server::selinux': } ->
  class { 'nagios::server::config':  } ~>
  class { 'nagios::server::service': }
}
