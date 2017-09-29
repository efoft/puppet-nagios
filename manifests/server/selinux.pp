#
class nagios::server::selinux {

  assert_private('This is private class')

  package { $nagios::params::selinux_package:
    ensure => $::nagios::server::install::package_ensure
  }

  ensure_resource('selboolean','daemons_enable_cluster_mode', {'value' => 'on', 'persistent' => true})

  # Bug 1426824 - Current selinux policy break nagios
  selinux::audit2allow { 'nagios_script_to_pool':
    avc_file => 'puppet:///modules/nagios/avc_nagios_script_to_pool.txt',
  }
}
