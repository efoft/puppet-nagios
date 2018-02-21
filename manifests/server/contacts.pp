#
class nagios::server::contacts {

  assert_private('This is private class')

  nagios::admin { 'nagiosadmin':
    alias    => 'Nagios Admin',
    password => $nagios::server::webpass,
    email    => $nagios::server::admin_email,
    tag      => $nagios::server::site,
  }
  nagios_contactgroup { 'admins':
    alias   => 'Nagios Administrators',
    members => $nagios::server::admin_members,
  }
}
