# === Define nagios::client::remote_service
#
define nagios::client::remote_service (
  Enum['present','absent'] $ensure = 'present',
  String $use                      = 'generic-service',
  String $command                  = "check_${title}",
  String $args                     = '',
  String $description              = upcase($title),
) {

  @@nagios_service { "${::fqdn}_${command}":
    ensure              => $ensure,
    use                 => $use,
    host_name           => $::fqdn,
    check_command       => "${command}${args}",
    service_description => $description,
  }
}
