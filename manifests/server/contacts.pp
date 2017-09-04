# === Class nagios::server::contacs
#
class nagios::server::contacts {

  nagios::admin { 'nagiosadmin':
    alias    => 'Nagios Admin',
    password => $nagios::server::webpass,
    email    => $nagios::server::admin_email,
  }
  nagios_contactgroup { 'admins':
    alias   => 'Nagios Administrators',
    members => $magios::server::admins_members,
  }
}
