# === Define nagios::admin ===
# Adds a user with access to GUI interface and a contact to be notified.
#
# Password is initially set but not verified/updated on subsequent puppet runs.
#
define nagios::admin (
  Enum['present','absent'] $ensure = 'present',
  String $password,
  String $email,
  Optional[String] $alias          = undef,
  String $use                      = 'generic-contact',
) {

  include ::nagios::server

  if $ensure == 'present' {
    @@exec { "update-${name}-to-passwd":
      path    => $::path,
      command => $nagios::server::encryption ?
        {
          'bcrypt' => "htpasswd -bB ${nagios::params::passwd_file} ${name} ${password}",
          'sha'    => "htpasswd -bs ${nagios::params::passwd_file} ${name} ${password}"
        },
      unless => "grep ${name} ${nagios::params::passwd_file}"
    }
  }
  else {
    @@exec { "remove-${name}-from-passwd":
      path    => ['/usr/bin','/bin'],
      command => "htpasswd -D ${nagios::params::passwd_file} ${name}",
      onlyif  => "grep ${name} ${nagios::params::passwd_file}",
    }
  }

  @@nagios_contact { $name:
    ensure => $ensure,
    use    => $use,
    alias  => $alias,
    email  => $email,
  }
}
