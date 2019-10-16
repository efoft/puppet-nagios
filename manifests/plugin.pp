# === Define nagios::plugin ===
# Installs plugin on a server or a client.
#
# === Parameters ===
# [*source*]
#   Can be 'package'(installed by yum) or 'script' (downloaded as file from puppet).
#
# [*script_name*]
#   File name located under module's files folder to be transfered to a client.
#
# [*dep_packages*]
#   Packages required to be install as dependencies. Usually is needed for script
#   type plugins. Normal packages are installed with dependencies automatically via
#   package manager.
#
define nagios::plugin (
  Enum['present','absent'] $ensure = 'present',
  Enum['package','script'] $source = 'package',
  String $package_name             = "nagios-plugins-${title}",
  String $script_name              = "check_${title}",
  Array $dep_packages              = [],
) {

  if $source == 'package' {
    ensure_packages($package_name, { ensure => $ensure })
  }
  elsif $source == 'script' {
    $script_install_options = {
      ensure => $ensure,
      source => "puppet:///modules/${module_name}/${script_name}",
      mode   => '0755',
    }
    ensure_resources('file', { "${nagios::params::plugin_dir}/${script_name}" => $script_install_options })
  }

  if $dep_packages {
    ensure_packages($dep_packages, { ensure => $ensure })
  }
}
