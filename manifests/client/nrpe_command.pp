# Puts a file on a client with defined nrpe command mapping local plugin execution
#
# === Parameters
#
# [*source*]
# Can be 'package'(installed by yum) or 'script' (downloaded as file from puppet).
#
# [*script_name*]
# File name located under module's files folder to be transfered to a client.
#
# [*dep_packages*]
# Packages required to be install as dependencies. Usually is needed for script
# type plugins. Normal packages are installed with dependencies automatically via
# package manager.
#
define nagios::client::nrpe_command (
  $ensure        = 'present',
  $template      = 'generic',
  $command       = "check_${title}",
  $args          = '',
  $plugin_dir    = $nagios::params::plugin_dir
) {

  validate_re($ensure, ['present','absent'], "`ensure` got invalid value of `${ensure}`")

  file { "${nagios::params::nrpe_include_dir}/${title}.cfg":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nrpe',
    mode    => '0640',
    content => template("nagios/nrpe_checks/${template}.cfg.erb"),
    notify  => Service[$nagios::params::nrpe_service],
  }
}
