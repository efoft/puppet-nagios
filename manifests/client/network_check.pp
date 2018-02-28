#
define nagios::client::network_check (
  Enum['present','absent'] $ensure     = 'present',
  # plugin params
  Enum['package','script'] $plugin_src = 'package',
  String $package_name                 = "${nagios::params::plugin_name_prefix}-${title}",
  String $script_name                  = "check_${title}",
  Array[String] $dep_packages          = [],
  # service params
  String $svc_cmd                      = "check_${title}",
  String $svc_cmd_args                 = '',
  String $description                  = upcase($title),
) {

  @@nagios::plugin { "network_check_${title}_${::fqdn}":
    ensure       => $ensure,
    shortname    => $title,
    source       => $plugin_src,
    package_name => $package_name,
    script_name  => $script_name,
    dep_packages => $dep_packages,
  }

  nagios::client::service { "network_check_${title}":
    ensure      => $ensure,
    command     => $svc_cmd,
    args        => $svc_cmd_args,
    description => $description,
  }
}
