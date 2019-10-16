#
class nagios::server::config::contacts inherits nagios::server {

  assert_private('This is private class')

  nagios::admin { 'nagiosadmin':
    alias    => 'Nagios Admin',
    password => $webpass,
    email    => $admin_email,
  }

  nagios_contactgroup { 'admins':
    alias   => 'Nagios Administrators',
    members => $admin_members,
  }
}
