# === Class nagios::server::import
#
# Collects exported resources
#
class nagios::server::import {

  Nagios::Plugin <<||>>

  Nagios_host <<||>> {
    notify => Service[$nagios::params::service_name],
  }
  Nagios_hostgroup <<||>> {
    notify => Service[$nagios::params::service_name],
  }
  Nagios_service <<||>> {
    notify => Service[$nagios::params::service_name],
  }
  Nagios_contact <<||>> {
    notify => Service[$nagios::params::service_name],
  }
  Nagios_contactgroup <<||>> {
    notify => Service[$nagios::params::service_name],
  }
  Exec <<| tag == 'nagios::admin' |>>
}
