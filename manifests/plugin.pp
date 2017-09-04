# Installs check plugin on server or client
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
define nagios::plugin (
  $ensure        = 'present',
  $shortname     = $title,
  $source        = 'package',
  $package_name  = "nagios-plugins-${shortname}",
  $script_name   = "check_${shortname}",
  $dep_packages  = [],
) {

  validate_re($ensure, ['present','absent'], "`ensure` got invalid value of `${ensure}`")
  validate_re($source, ['package','script'], "`source` can have values of: `package` or `script`")

  if $source == 'package' {
    ensure_packages($package_name, {'ensure' => $ensure})
  }
  else {
    ensure_resources('file', { "${nagios::params::plugin_dir}/${script_name}" => {'ensure' => $ensure, 'source' => "puppet:///modules/nagios/${script_name}"}})
  }

  if $dep_packages {
    ensure_packages($dep_packages, {'ensure' => $ensure})
  }
}
