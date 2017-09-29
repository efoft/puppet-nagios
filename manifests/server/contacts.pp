#
class nagios::server::contacts {

  assert_private('This is private class')

  nagios::admin { 'nagiosadmin':
    alias    => 'Nagios Admin',
    password => $nagios::server::webpass,
    email    => $nagios::server::admin_email,
    tag      => '127.0.0.1',
  }
  nagios_contactgroup { 'admins':
    alias   => 'Nagios Administrators',
    members => $magios::server::admins_members,
  }
}
