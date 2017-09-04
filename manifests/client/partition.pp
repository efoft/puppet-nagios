# Should be used to iterate $::partitions fact
#
define nagios::client::partition(
  $filesystem  = undef,
  $mount       = undef,
  $size        = undef,
  $size_bytes  = undef,
  $uuid        = undef
) {

  if $mount != undef and $mount != 'swap' {
    nagios::client::service { $mount:
      command     => "check_nrpe_disk!${mount}",
      description => "Usage for ${mount}",
    }
  }
}
