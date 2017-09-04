Facter.add(:drbd_used) do
  confine :kernel => "Linux"
  setcode do
    File.exist? '/proc/drbd'
  end
end
