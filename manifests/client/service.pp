#
define nagios::client::service (
  Enum['present','absent'] $ensure = 'present',
  String $use                      = 'generic-service',
  String $host_name                = $::fqdn,
  String $command                  = undef,
  String $args                     = '',
  String $description              = upcase($title),
) {

  @@nagios_service { "${::fqdn}_${command}_${title}":
    ensure              => $ensure,
    use                 => $use,
    host_name           => $host_name,
    check_command       => "$command${args}",
    service_description => $description,
  }
}
