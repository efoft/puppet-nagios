#
# @summary Adds a user with access to GUI interface and a contact to be notified.
#
# Password is updated each run.
#
# TODO: what if 2+ servers have the same contact
#
define nagios::admin (
  Enum['present','absent'] $ensure    = 'present',
  String                   $password,
  String                   $email,
  Optional[String]         $alias     = undef,
  String                   $use       = 'generic-contact',
) {

  include nagios::server
  $passwd_file = $nagios::server::passwd_file

  # webpass encryption type
  $encryption  = $nagios::server::encryption ?
  {
    undef   => defined('$::apache_version') ?
    {
      true   => (versioncmp($::apache_version, '2.4') >= 0) ?
      {
        true  => 'bcrypt', # only supported with Apache 2.4+
        false => 'sha'     # Apache 2.2
      },
      false  => 'sha',
    },
    default => $nagios::server::encryption,
  }

  if $ensure == 'present' {
    exec { "update-${name}-to-passwd":
      path    => $::path,
      command => $encryption ?
        {
          'bcrypt' => "htpasswd -bB ${passwd_file} ${name} ${password}",
          'sha'    => "htpasswd -bs ${passwd_file} ${name} ${password}"
        },
      unless => "htpasswd -bv ${passwd_file} ${name} ${password}",
    }
  }
  else {
    exec { "remove-${name}-from-passwd":
      path    => ['/usr/bin','/bin'],
      command => "htpasswd -D ${passwd_file} ${name}",
      onlyif  => "grep ${name} ${passwd_file}",
    }
  }

  nagios_contact { $name:
    ensure => $ensure,
    use    => $use,
    alias  => $alias,
    email  => $email,
  }
}
