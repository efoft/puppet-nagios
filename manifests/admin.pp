# === Define nagios::admin ===
# Adds a user with access to GUI interface and a contact to be notified.
#
# For Apache 2.4 password is verified each puppet run and updated if doesn't match.
# But for 2.2 version there is no way to verity the htpasswd so it only assigned once
# and not updated any longer.
#
define nagios::admin (
  Enum['present','absent'] $ensure = 'present',
  String $password,
  String $email,
  Optional[String] $alias          = undef,
  String $use                      = 'generic-contact',
) {

  $vers = (versioncmp($::apache_version, '2.4') >= 0) ?
  {
    true  => '24',
    false => '22'
  }

  if $ensure == 'present' {
    @@exec { "update-${name}-to-passwd":
      path    => ['/usr/bin','/bin'],
      command => $vers ?
        {
          '24' => "htpasswd -bB ${nagios::params::passwd_file} ${name} ${password}", # Bcrypt
          '22' => "htpasswd -bs ${nagios::params::passwd_file} ${name} ${password}"  # SHA
        },
      unless => $vers ?
        {
          '24' => "htpasswd -bv ${nagios::params::passwd_file} ${name} ${password}",
          '22' => "grep ${name} ${nagios::params::passwd_file}"
        },
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
