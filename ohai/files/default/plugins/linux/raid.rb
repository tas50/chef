provides 'raid/devices'

raid Mash.new

# Sample data
# 05:00.0 "RAID bus controller" "Hewlett-Packard Company" "Smart Array G6 controllers" -r01 "Hewlett-Packard Company" "Smart Array P410i"
# 11:00.0 "RAID bus controller" "Areca Technology Corp." "Device 1880" -r05 "Areca Technology Corp." "Device 1880"
# 01:00.0 "RAID bus controller" "LSI Logic / Symbios Logic" "MegaRAID SAS 1078" -r04 "Dell" "PERC 6/i Integrated RAID Controller"
# 05:00.0 "Serial Attached SCSI controller" "LSI Logic / Symbios Logic" "SAS2008 PCI-Express Fusion-MPT SAS-2 [Falcon]" -r02 "LSI Logic / Symbios Logic" "SAS2008 PCI-Express Fusion-MPT SAS-2 [Falcon]"

# PCI ID / TYPE / VENDOR / DEVICE NAME / -rREVISION / SUBVENDOR / SUBSYSTEM NAME
regex = Regexp.new("(.*) \"(.*)\" \"(.*)\" \"(.*)\" -r(.*) \"(.*)\" \"(.*)\"")

devices = []

`/usr/bin/lspci -m | /bin/grep -iE 'raid|MPT'`.each_line do |l|
  m = regex.match(l)
  if m
    data = Hash.new
    data[:pciid] = m[1]
    data[:vendor] = m[3]
    data[:susbsystem] = m[7]
    data[:devicename] = m[4]
    data[:revision] = m[5]
    data[:subvendor] = m[6]
    devices.push(data)
  end
end

raid[:devices] = devices
