# === Class nagios::server::service
#
#
class nagios::server::service(
  $service_name = $nagios::params::service_name
) inherits ::nagios::params {

  $service_ensure = $nagios::server::ensure ? {
    true        => 'running',
    'installed' => 'running',
    false       => 'stopped',
    'absent'    => 'stopped',
    default => $nagios::server::ensure
  }

  $service_enable = $service_ensure ? {
    'running' => true,
    'stopped' => false
  }

  validate_re($service_ensure, ['running', 'stopped'], "`${service_ensure}` is not a valid value")

  service { $service_name:
    ensure => $service_ensure,
    enable => $service_enable,
    alias  => 'alias_nagios_service',
  }
}
