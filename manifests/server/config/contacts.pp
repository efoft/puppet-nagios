#
class nagios::server::config::contacts inherits nagios::server {

  nagios::admin { 'nagiosadmin':
    username => 'nagiosadmin',
    alias    => 'Nagios Admin',
    password => $webpass,
    email    => $admin_email,
  }

  nagios_contactgroup { 'admins':
    alias   => 'Nagios Administrators',
    members => $admin_members,
  }
}
