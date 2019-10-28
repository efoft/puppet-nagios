#
class nagios::params {

  case $::osfamily {
    'redhat': {
      $package_name        = 'nagios'
      $plugin_name_prefix  = 'nagios-plugins'              # a common part of nagios plugins packages names
      $selinux_package     = 'nagios-selinux'
      $service_name        = 'nagios'
      $server_side_plugins = ['nagios-plugins-nrpe', 'nagios-plugins-ping']
      $plugin_dir          = '/usr/lib64/nagios/plugins'
      $nagios_cfg          = '/etc/nagios/nagios.cfg'
      $passwd_file         = '/etc/nagios/passwd'
      $managed_cfg_files   = [
        '/etc/nagios/nagios_host.cfg',
        '/etc/nagios/nagios_hostgroup.cfg',
        '/etc/nagios/nagios_service.cfg',
        '/etc/nagios/nagios_command.cfg',
        '/etc/nagios/nagios_contact.cfg',
        '/etc/nagios/nagios_contactgroup.cfg',
      ]
      # nrpe
      $nrpe_package       = 'nrpe'
      $nrpe_cfg_file      = '/etc/nagios/nrpe.cfg'
      $nrpe_cfg_template  = 'nrpe.cfg.erb'
      $nrpe_service       = 'nrpe'
      $nrpe_include_dir   = '/etc/nrpe.d'
      # other
      $mysql_socket_path  = '/var/lib/mysql/mysql.sock'
    }
    'windows': {
      #nscp
      $nrpe_package       = 'nscp'
      $nrpe_cfg_file      = 'C:/Program Files/NSClient++/nsclient.ini'
      $nrpe_cfg_template  = 'nsclient.ini.erb'
      $nrpe_service       = 'nscp'
      $nrpe_include_dir   = undef
    }
    default: {
      fail('Sorry! Your OS is not supported')
    }
  }
}
