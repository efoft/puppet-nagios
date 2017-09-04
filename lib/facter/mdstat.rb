Facter.add(:mdstat_devices) do
  confine :kernel => "Linux"
  setcode do
    str = Facter::Util::Resolution.exec("cat /proc/mdstat | egrep '^md'")
    hash = {}
    str.split("\n").each do |pair|
      key,value = pair.split(/:/)
      hash[key.strip] = value.strip
    end
    hash
  end
end

Facter.add(:mdstat_has_devices) do
  confine :kernel => "Linux"
  setcode do
    Facter.value(:mdstat_devices) != {}
  end
end
