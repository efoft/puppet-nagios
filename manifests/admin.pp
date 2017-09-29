#
define nagios::admin (
  Enum['present','absent'] $ensure = 'present',
  String $password,
  String $email,
  Optional[String] $alias          = undef,
  String $use                      = 'generic-contact',
) {

  if $ensure == 'present' {
    @@exec { "update-${name}-to-passwd":
      path    => ['/usr/bin'],
      command => "htpasswd -bB ${nagios::params::passwd_file} ${name} ${password}",
      unless  => "htpasswd -bv ${nagios::params::passwd_file} ${name} ${password}",
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
