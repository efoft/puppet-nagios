# Installs plugin, nrpe command on a client and defines a service as exported resource
# to be collected on the server
#
define nagios::client::nrpe_check (
  Enum['present','absent'] $ensure     = 'present',
  # plugin params
  Enum['package','script'] $plugin_src = 'package',
  String $package_name                 = "${nagios::params::plugin_name_prefix}-${title}",
  String $script_name                  = "check_${title}",
  Array[String] $dep_packages          = [],
  # command params
  String $clnt_cmd_name                = "check_${title}",
  String $clnt_cmd_exec                = $clnt_cmd_name,
  String $clnt_cmd_args                = '',
  # service params
  Boolean $manage_svc                  = true,
  Boolean $use_ssl                     = true,
  String $svc_cmd_args                 = '',
  String $description                  = upcase($title),
) {

  $plugin = { $title => {
      ensure         => $ensure,
      source         => $plugin_src,
      package_name   => $package_name,
      script_name    => $script_name,
      dep_packages   => $dep_packages,
    }
  }
  ensure_resources('nagios::plugin', $plugin)

  $nrpe_cmd_cfg = {
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nrpe',
    mode    => '0640',
    content => template("${module_name}/nrpe_command.cfg.erb"),
    notify  => Service[$nagios::params::nrpe_service],
  }
  ensure_resource('file', "${nagios::params::nrpe_include_dir}/${clnt_cmd_name}.cfg", $nrpe_cmd_cfg)

  if $manage_svc {

    $_svc_cmd = empty($svc_cmd_args) ?
    {
      true  => 'check_nrpe',
      false => 'check_nrpe_args',
    }
    $_svc_cmd_final = $use_ssl ?
    {
      true  => $_svc_cmd,
      false => "${_svc_cmd}_nossl",
    }

    nagios::client::service { "nrpe_check_${title}":
      ensure      => $ensure,
      command     => "${_svc_cmd_final}!${clnt_cmd_name}",
      args        => $svc_cmd_args,
      description => $description,
    }
  }
}
