# === Class nagios::server::import ===
#
# Collects exported resources.
#
class nagios::server::import {

  Nagios::Plugin <<| tag == $nagios::server::site |>>
  Nagios_host <<| tag == $nagios::server::site |>>                     { notify => Service[$nagios::params::service_name] }
  Nagios_hostgroup <<| tag == $nagios::server::site |>>                { notify => Service[$nagios::params::service_name] }
  Nagios_service <<| tag == $nagios::server::site |>>                  { notify => Service[$nagios::params::service_name] }
  Nagios_contact <<| tag == $nagios::server::site |>>                  { notify => Service[$nagios::params::service_name] }
  Nagios_contactgroup <<| tag == $nagios::server::site |>>             { notify => Service[$nagios::params::service_name] }
  Exec <<| tag == 'nagios::admin' and tag == $nagios::server::site |>> { notify => Service[$nagios::params::service_name] }
}
