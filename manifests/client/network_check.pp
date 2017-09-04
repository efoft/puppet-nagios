#
define nagios::client::network_check (
  $ensure        = 'present',
  # plugin params
  $plugin_source = 'package',
  $package_name  = "${nagios::params::plugin_name_prefix}-${title}",
  $script_name   = "check_${title}",
  $dep_packages  = [],
  # service params
  $command       = "check_${title}",
  $args          = '',
  $description   = upcase($title),
) {

  validate_re($ensure, ['present','absent'], "`ensure` got invalid value of `${ensure}`")
  validate_re($plugin_source, ['package','script'], "`source` got invalid value of `${plugin_source}`")

  #$plugin = { $title => {
  #    ensure         => $ensure,
  #    source         => $plugin_source,
  #    package_name   => $package_name,
  #    script_name    => $script_name,
  #    dep_packages   => $dep_packages,
  #  }
  #}
  #ensure_resources('nagios::plugin', $plugin)
  @@nagios::plugin { "network_check_${title}_${::fqdn}":
    ensure       => $ensure,
    shortname    => $title,
    source       => $plugin_source,
    package_name => $package_name,
    script_name  => $script_name,
    dep_packages => $dep_packages,
  }

  nagios::client::service { "network_check_${title}":
    ensure      => $ensure,
    command     => "${command}${args}",
    description => $description,
  }
}
