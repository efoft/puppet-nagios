#
class nagios::server::install {

  assert_private('This is private class')

  $package_ensure = $nagios::server::ensure ? {
    'present'   => 'present',
    'absent'    => 'purged',
  }

  package { $nagios::params::package_name:
    ensure => $package_ensure,
  }

  ensure_packages($nagios::params::server_side_plugins, {'ensure' => $package_ensure}) 
}
