#
class nagios::server::install inherits nagios::server {

  assert_private('This is private class')

  ensure_packages(concat($server_side_plugins, $package_name), {'ensure' => $ensure ? {'absent' => 'purged', default => $ensure}})
}
