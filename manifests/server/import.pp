# === Class nagios::server::import
#
# Collects exported resources
#
class nagios::server::import {

  Nagios::Plugin <<||>>

  Nagios_host <<| tag == '127.0.0.1' or tag == $::fqdn or tag == $::ipaddress |>> {
    notify => Service[$nagios::params::service_name],
  }
  Nagios_hostgroup <<| tag == '127.0.0.1' or tag == $::fqdn or tag == $::ipaddress |>> {
    notify => Service[$nagios::params::service_name],
  }
  Nagios_service <<| tag == '127.0.0.1' or tag == $::fqdn or tag == $::ipaddress |>> {
    notify => Service[$nagios::params::service_name],
  }
  Nagios_contact <<| tag == '127.0.0.1' or tag == $::fqdn or tag == $::ipaddress |>> {
    notify => Service[$nagios::params::service_name],
  }
  Nagios_contactgroup <<| tag == '127.0.0.1' or tag == $::fqdn or tag == $::ipaddress |>> {
    notify => Service[$nagios::params::service_name],
  }
  Exec <<| tag == 'nagios::admin' and (tag == '127.0.0.1' or tag == $::fqdn or tag == $::ipaddress) |>>
}
