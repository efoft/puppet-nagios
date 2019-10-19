#
# @summary Adds a user with access to GUI interface and a contact to be notified.
#
# Password is updated each run.
#
# TODO: what if 2+ servers have the same contact
#
define nagios::admin (
  Enum['present','absent'] $ensure    = 'present',
  String[1]                $username,
  String[1]                $password,
  String                   $email,
  Optional[String]         $aliasname = undef,             # because alias is metaparam
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
    exec { "update-${username}-to-passwd":
      path    => $::path,
      command => $encryption ?
        {
          'bcrypt' => "htpasswd -bB ${passwd_file} ${username} ${password}",
          'sha'    => "htpasswd -bs ${passwd_file} ${username} ${password}"
        },
      unless => "htpasswd -bv ${passwd_file} ${username} ${password}",
    }
  }
  else {
    exec { "remove-${username}-from-passwd":
      path    => ['/usr/bin','/bin'],
      command => "htpasswd -D ${passwd_file} ${username}",
      onlyif  => "grep ${username} ${passwd_file}",
    }
  }

  #nagios_contact { $name:
  #  ensure => $ensure,
  #  use    => $use,
  #  alias  => $aliasname,
  #  email  => $email,
  #}

  ensure_resource('nagios_contact', $username, {
    ensure => $ensure,
    use    => $use,
    alias  => $aliasname,
    email  => $email,
  })
}
