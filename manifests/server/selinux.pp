#
class nagios::server::selinux inherits nagios::server::install {

  assert_private('This is private class')

  package { $selinux_package:
    ensure => $ensure ? {'absent' => 'purged', default => $ensure},
  }

  ensure_resource('selboolean','daemons_enable_cluster_mode', {'value' => 'on', 'persistent' => true})

  if $ensure == 'present' {
    if $::operatingsystemmajrelease == '7' {
      # Bug 1426824 - Current selinux policy break nagios
      selinux::audit2allow { 'nagios_script_to_pool':
        avc_file => 'puppet:///modules/nagios/avc_nagios_script_to_pool.txt',
      }
    }
    elsif $::operatingsystemmajrelease == '6' {
      selinux::audit2allow { 'nagios_to_syslog':
        avc_file => 'puppet:///modules/nagios/avc_nagios_to_syslog.txt',
      }
    }
  }
}
