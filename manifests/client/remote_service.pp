# === Define nagios::client::remote_service
#
define nagios::client::remote_service (
  $ensure        = 'present',
  $use           = 'generic-service',
  $command       = "check_${title}",
  $args          = '',
  $description   = upcase($title),
) {

  validate_re($ensure, ['present','absent'], "`ensure` got invalid value of `${ensure}`")

  ensure_packages($package, {'ensure' => $ensure})

  @@nagios_service { "${::fqdn}_${command}":
    ensure              => $ensure,
    use                 => $use,
    host_name           => $::fqdn,
    check_command       => "${command}${args}",
    service_description => $description,
  }
}
