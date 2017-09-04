# === Class nagios::server::install
#
class nagios::server::install {

  # 'purged' resolves dependency conflicts
  $package_ensure = $nagios::server::ensure ? {
    true        => 'present',
    'installed' => 'present',
    false       => 'purged',
    'absent'    => 'purged',
    default     => $nagios::server::ensure
  }

  validate_re($package_ensure, ['present', 'purged'], "`${package_ensure}` is not a valid value")

  package { $nagios::params::package_name:
    ensure => $package_ensure,
    alias  => 'alias_nagios_package',
  }

  ensure_packages($nagios::params::server_side_plugins, {'ensure' => $package_ensure}) 
}
