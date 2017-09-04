# Installs plugin, nrpe command on a client and defines a service as exported resource
# to be collected on the server
#
define nagios::client::nrpe_check (
  $ensure         = 'present',
  # plugin params
  $plugin_source  = 'package',
  $package_name   = "${nagios::params::plugin_name_prefix}-${title}",
  $script_name    = "check_${title}",
  $dep_packages   = [],
  # command params
  $local_cmd      = "check_${title}",
  $local_cmd_args = '',
  # service params
  $nrpe_cmd       = "check_nrpe_${title}",
  $nrpe_cmd_args  = '',
  $description    = upcase($title),
) {

  validate_re($ensure, ['present','absent'], "`ensure` got invalid value of `${ensure}`")
  validate_re($plugin_source, ['package','script'], "`source` got invalid value of `${plugin_source}`")

  $plugin = { $title => {
      ensure         => $ensure,
      source         => $plugin_source,
      package_name   => $package_name,
      script_name    => $script_name,
      dep_packages   => $dep_packages,
    }
  }
  ensure_resources('nagios::plugin', $plugin)

  $command = { $title => {
      ensure          => $ensure,
      command         => $local_cmd,
      args            => $local_cmd_args,
    }
  }
  ensure_resources('nagios::client::nrpe_command', $command)

  nagios::client::service { $title:
    ensure      => $ensure,
    command     => $nrpe_cmd,
    args        => $nrpe_cmd_args,
    description => $description,
  }
}
