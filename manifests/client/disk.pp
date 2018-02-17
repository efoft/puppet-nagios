# Should be used to iterate $::disks fact
#
define nagios::client::disk(
  $model       = undef,
  $size        = undef,
  $size_bytes  = undef,
  $vendor      = undef
) {

  unless $title =~ /^(fd|sr)/ or $size_bytes == 0 {
    nagios::client::service { $title:
      command     => "check_nrpe_ide_smart!/dev/${title}",
      description => "SMART for /dev/${title}",
    }
  }
}
