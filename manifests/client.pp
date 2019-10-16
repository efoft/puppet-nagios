#
# @summary    Installs and configures nagios client on Linux and Windows.
#
# @param servers    From where nrpe allows connections from. Can be IP addresses or resolvable hostnames.
# @param myip              IP reachable from nagios server.
# @param nrpe_listen_port  Default: 5666
# @param nrpe_bind_address If not set, 127.0.0.1 is used.
# @param nrpe_allow_args   nrpe.cfg's dont_blame_nrpe param which allows args to be passed via check_nrpe.
# @param nrpe_debug        Corresponds to nrpe.cfg debug parameter.
#
# @param win_ext_scripts
#   Use of nsclient++ external scripts mechanism that allows to call external programs on client and return
#   the result of their execution. We assume that executable itself is already in place.
#   Hash should look like this (hiera format):
#     ext_scripts:
#       intel_rst_raid:
#         command: "c:\\nagios\\check_intel_rst\\check_intel_rst.exe path=c:\\nagios\\check_intel_rst"
#         use: generic-service
#
class nagios::client(
  Enum['present','absent']      $ensure            = 'present',
  Array[String]                 $servers,
  Stdlib::Ip::Address           $myip              = $::ipaddress,
  Numeric                       $nrpe_listen_port  = 5666,
  Optional[Stdlib::Ip::Address] $nrpe_bind_address = undef,
  Boolean                       $nrpe_allow_args   = true,
  Boolean                       $nrpe_debug        = false,
  Hash                          $win_ext_scripts   = {},
) inherits ::nagios::params {

  # Install nrpe package
  package { $nrpe_package:
    ensure => $ensure ? { 'present' => 'present', 'absent' => 'purged' },
  }

  # If SELinux in place, fix policy
  if $::kernel == 'linux' {
    package { 'nrpe-selinux':
      ensure => $ensure ? { 'present' => 'present', 'absent' => 'purged' },
    }
  }

  # Always allow to connect from localhost
  $_servers = unique(concat(['127.0.0.1'], $servers))

  # Main config
  file { $nrpe_cfg_file:
    ensure  => $ensure,
    content => template("${module_name}/${nrpe_cfg_template}"),
    notify  => Service[$nrpe_service],
    require => Package[$nrpe_package],
  }

  # Include dir
  if $nrpe_include_dir {
    file { $nrpe_include_dir:
      ensure  => $ensure ? { 'present' => 'directory', 'absent' => 'absent' },
      recurse => true,
      force   => true,
      purge   => true,
      require => Package[$nrpe_package],
    }
  }

  # Service
  service { $nrpe_service:
    ensure => $ensure ? { 'present' => 'running', 'absent' => undef },
    enable => $ensure ? { 'present' => true, 'absent'      => undef },
  }
}
