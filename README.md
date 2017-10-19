# puppet-nagios module
Installs and configures nagios server and client on RHEL-based distro and also a client on Windows.
The server doesn't installs client automatically, include it separately. Client hosts and their resources are exported and then collected on server side.

There are a lot of default checks that are enabled by default and some of them (like mdadm, drdb) are auto-detected and thus enabled.

Specific checks like mySQL, PostgreSQL, MongoDB, Apache etc must be enabled in client class definition.
Resources like DBs can be monitored locally or via network connection from the server. For this to work the DB must listen on public address and firewall must allow such connection. Related checks have meaningful names like mysql_local and mysql_remote subsequently.

## Requirements
Module uses exported resources so PuppetDB is required.

## Installation
Clone into puppet's modules directory:
```
git clone https://github.com/efoft/puppet-nagios.git nagios
```

## Example of usage
Server:
```
class { 'nagios::server':
  ensure      => $ensure,
  admin_email => $admin_email,
  webpass     => $webpass,
}
```

Client (linux):
```
class { 'nagios::client':
    myip              => $::ipaddress,
    servers           => ['X.X.X.X'],
    contacts          => $contacts,
    nrpe_bind_address => $servers ? {
      ['127.0.0.1']   => '127.0.0.1',
      '127.0.0.1'     => '127.0.0.1',
      default         => undef
    },
    defaultchecks     => false,
    mysql_local       => true,
    mysql_remote      => true,
    mysql_repl        => true,
    mysql_user        => 'mysql',
    mysql_pass        => 'password',
    pgsql_local       => true,
    pgsql_remote      => false,
    pgsql_user        => 'pgsql',
    pgsql_pass        => 'secret',
    mongo_local       => true,
    mongo_remote      => true,
    http              => true,
    imap              => true,
    pop               => true,
    bacula            => true,
    bacula_pass       => 'password_bacula',
    smtp              => true,
  }
```

Client (Windows):
```
class { 'nagios::client':
    myip              => $::ipaddress,
    servers           => ['X.X.X.X'],
    defaultchecks     => true,
    mssql_remote      => true,
    mssql_user        => 'mssqlmon',
    mssql_pass        => 'password',
    win_services      => ['power','app1','app2'],
  }
```
