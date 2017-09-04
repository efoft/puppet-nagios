# === define nagios::admin
#
define nagios::admin(
  $ensure    = 'present',
  $password  = undef,
  $alias     = undef,
  $email     = undef,
  $use       = 'generic-contact',
) {

  # In Puppet 4 empty string is not falsey as in Puppet 3
  # So we check it mapped to boolean (for undef) and for emptyness
  if ! $password or empty($password){
    fail('Parameter password is required for contact')
  }
  if ! $email or empty($email) {
    fail('Parameter email is required for contact')
  }

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
