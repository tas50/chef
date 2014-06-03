#
# Author:: Nicolas Szalay <nico@rottenbytes.info>
# Plugin:: raid
#
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.

Ohai.plugin(:Raid) do

  provides 'raid/devices'

  collect_data(:linux) do
    raid Mash.new

    # Sample data
    # 05:00.0 "RAID bus controller" "Hewlett-Packard Company" "Smart Array G6 controllers" -r01 "Hewlett-Packard Company" "Smart Array P410i"
    # 11:00.0 "RAID bus controller" "Areca Technology Corp." "Device 1880" -r05 "Areca Technology Corp." "Device 1880"
    # 01:00.0 "RAID bus controller" "LSI Logic / Symbios Logic" "MegaRAID SAS 1078" -r04 "Dell" "PERC 6/i Integrated RAID Controller"
    # 05:00.0 "Serial Attached SCSI controller" "LSI Logic / Symbios Logic" "SAS2008 PCI-Express Fusion-MPT SAS-2 [Falcon]" -r02 "LSI Logic / Symbios Logic" "SAS2008 PCI-Express Fusion-MPT SAS-2 [Falcon]"

    # PCI ID / TYPE / VENDOR / DEVICE NAME / -rREVISION / SUBVENDOR / SUBSYSTEM NAME
    regex = Regexp.new("(.*) \"(.*)\" \"(.*)\" \"(.*)\" -r(.*) \"(.*)\" \"(.*)\"")

    devices = []

    so = shell_out("lspci -m | /bin/grep -iE 'raid|MPT'")
    so.stdout.each_line do |l|
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
  end
end
