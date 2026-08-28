# Resources for Yoga Pro 7 14AHP9 on Linux
This repository contains my patches, drivers and other resources useful for those who want a better Linux experience on this laptop.  
My model is specifically a Yoga Pro 7 14AHP9 with AMD Ryzen 7 8845HS, RTX 3050 6GB and MEDIATEK MT7922 802.11ax.  
It works well out of the box, but these tweaks can improve the experience.

## Fixes included in this repository
* Patched ideapad-laptop (ideadpad_acpi) driver:
  * Fixes charging mode issues such as `ideapad_acpi VPC2004:00: unexpected charge_types: both [Fast] and [Long_Life] are enabled`
  * Fixes keyboard backlight reporting to udev
  * Adds support for `Auto` keyboard backlight mode (this is not supported by userspace tools like KDE PowerDevil and will show as "High" brightness)
* Patched ACPI DSDT Table
  * Fixes ACPI Error spam while booting, charging, and resuming from sleep, this potentially fixes some issues.
  ```
  [    0.277775] ACPI BIOS Error (bug): AE_AML_PACKAGE_LIMIT, Index (0x000000001) is beyond end of object (length 0x1) (20260408/exoparg2-393)
  [    0.277778] ACPI Error: Aborting method \_SB.PCI0.LPC0.EC0.PSWS due to previous error (AE_AML_PACKAGE_LIMIT) (20260408/psparse-545)
  [    0.277780] ACPI Error: Aborting method \_SB.PCI0.LPC0.EC0._Q15 due to previous error (AE_AML_PACKAGE_LIMIT) (20260408/psparse-545)
  ```
* NVIDIA tweaks:
  * Long delay when resuming from sleep, and other issues related to sleep and hibernate
    * Run `sudo systemctl enable --now nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service`
    * Inside this repository, run `sudo ./fix-nvidia-freeze.sh` (make sure the file is executable)
  * Better power limits
    * Run `sudo systemctl enable --now nvidia-powerd.service`
    * Adjust the power profile in the panel of KDE/GNOME, or use `powerprofilesctl`, now the nvidia dGPU power limit will be adjusted accordingly to your selected power-profile, bypassing the stock limit of 35W, up to 65W (prepare the charger, also it gets REALLY loud)
    
## Installation
### Patched ideapad-laptop driver
You can include the patched driver in your custom kernel, or use DKMS. I will put some guide here if i don't forget.  
If you use Arch Linux/CachyOS/EndavourOS or other Arch-based OS, do this, after cloning the repository:
```
cd ideapad-laptop
makepkg -si
```
Reboot, or hotswap the driver:
```
sudo modprobe -r ideapad_laptop
sudo modprobe ideapad_laptop
```

### Patching the ACPI DSDT table
Only do this if you have this exact laptop model, and if you see the errors in your kernel log.  
There are many ways to inject a patched DSDT table, and you should check some wiki first. This is the method i use in my mkinitcpio+UKI setup.
`dsdt.aml` is the precompiled table, `dsdt.dsl` contains the source code, which you can modify and compile yourself. Check the ArchWiki article on this.
1. Copy `acpi/dsdt.aml` to `/etc/acpi/dsdt.aml`
2. Paste the contents of `acpi/acpi_dsdt` inside `/etc/initcpio/install/acpi_dsdt`
3. Inside `/etc/mkinitcpio.conf` add the hook after microcode, it should look like this
```
HOOKS=(base udev microcode acpi_dsdt autodetect modconf kms ...)
```
4. Regenerate initramfs by running `sudo mkinitcpio -P`
5. Reboot, you should see this in your logs if the injection succeded:
```
[    0.013531] ACPI: DSDT ACPI table found in initrd [kernel/firmware/acpi/dsdt.aml][0x13e88]
[    0.013758] ACPI: Table Upgrade: override [DSDT-LENOVO-CB-01   ]
[    0.013759] ACPI: DSDT 0x000000007AFD3000 Physical table override, new table: 0x0000000077097000
[    0.013760] ACPI: DSDT 0x0000000077097000 013E88 (v02 LENOVO CB-01    00000002 INTL 20251212)
```

Other tweaks are applied individually. Look above.

## Unresolved issues
### 1. Error on resume
If your laptop has a Mediatek WIFI chip like mine, when your laptop resumes from sleep you will see an error in dmesg:
```
80977.711477] ACPI BIOS Error (bug): Could not resolve symbol [^^^GPP6.RTKW], AE_NOT_FOUND (20260408/psargs-365)
[80977.711490] ACPI Error: Aborting method \_SB.PCI0.LPC0.EC0.UPHK due to previous error (AE_NOT_FOUND) (20260408/psparse-545)
[80977.711496] ACPI Error: Aborting method \_SB.PEP._DSM due to previous error (AE_NOT_FOUND) (20260408/psparse-545) 
```
This is harmless and doesn't cause any issues, but one day i will probably patch the DSDT to fix this.

### 2. Error on USB-C connector
When plugging or unplugging a USB-C charger, charging state notification will be delayed by exactly 10 seconds, and will show errors in dmesg:
```
[  770.996993] ucsi_acpi USBC000:00: ucsi_handle_connector_change: GET_CONNECTOR_STATUS failed (-110)
[  770.997010] ucsi_acpi USBC000:00: ucsi_handle_connector_change entered without EVENT_PENDING
```
This seems to be harmless, but the delay is annoying. This is a firmware issue and cannot be fixed. The solution to the delay is to patch the ucsi_acpi driver, maybe i will do that one day.

### 3. IR sensor randomly stops working
The IR sensor is detected and outputs a black-white image correctly and can be used with Howdy for face biometrics. However, after some time or caused by some unknown circumstances, the IR sensor will only output a pure black image. TODO: investigate

### 4. Random NVIDIA errors
Sometimes, when booting, resuming or some other random events, the Nvidia driver can throw some errors, such as:
```
NVRM: RmHandleDNotifierEvent: RmHandleDNotifierEvent: Failed to handle ACPI D-Notifier event, status=0x11
NVRM: rm_power_source_change_event: rm_power_source_change_event: Failed to handle Power Source change event, status=0x11 
```
This is probably harmless, but i will need to investigate.

## Other notes
* Upgrading BIOS firmware requires booting to Windows, if you don't dualboot, use a recovery WinPE iso from a USB drive. There is no other way, i tried unpacking the update package and running it in EFI shell, and it just refuses to start.
* Someone on ArchWiki mentioned something about 3.5mm headphone jack needing a tweak in PipeWire/alsamixer to work. I didn't test it yet.

## License

This project, is licensed under the **GNU General Public License v2.0 (GPL-2.0)**.  
The reason for this license, is because i include a full source of the `ideapad-laptop` module copied from the Linux kernel, and that forces the GPL2 license. I could replace the driver source with just a git patch or dual license this repository or move the driver to a different repository, but im lazy lol, so GPL2 it is.
