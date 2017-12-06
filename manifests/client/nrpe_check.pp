# Installs plugin, nrpe command on a client and defines a service as exported resource
# to be collected on the server
#
define nagios::client::nrpe_check (
  Enum['present','absent'] $ensure        = 'present',
  # plugin params
  Enum['package','script'] $plugin_source = 'package',
  String $package_name                    = "${nagios::params::plugin_name_prefix}-${title}",
  String $script_name                     = "check_${title}",
  Array[String] $dep_packages             = [],
  # command params
  String $local_cmd                       = "check_${title}",
  String $local_cmd_args                  = '',
  # service params
  String $nrpe_cmd                        = "check_nrpe_${title}",
  String $nrpe_cmd_args                   = '',
  String $description                     = upcase($title),
) {

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
