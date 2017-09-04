# Should be used to iterate $::disks fact
#
define nagios::client::disk(
  $model       = undef,
  $size        = undef,
  $size_bytes  = undef,
  $vendor      = undef
) {

  unless $title =~ /^(fd|sr)/ {
    nagios::client::service { $title:
      command     => "check_nrpe_ide_smart!${title}",
      description => "SMART for ${title}",
    }
  }
}
