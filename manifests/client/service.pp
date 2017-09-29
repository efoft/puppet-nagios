#
define nagios::client::service (
  $ensure        = 'present',
  $use           = 'generic-service',
  $host_name     = $::fqdn,
  $command       = "check_nrpe_${title}",
  $args          = '',
  $description   = upcase($title),
) {

  validate_re($ensure, ['present','absent'], "`ensure` got invalid value of `${ensure}`")

  if ! $command {
    fail('Parameter command is required')
  }

  @@nagios_service { "${::fqdn}_check_nrpe_${title}":
    ensure              => $ensure,
    use                 => $use,
    host_name           => $host_name,
    check_command       => "$command${args}",
    service_description => $description,
  }
}
