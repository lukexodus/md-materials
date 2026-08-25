## TPM


### What is TPM

TPM is a specialized hardware component that enhances computer security through features like cryptographic key storage, authentication, system integrity verification, disk encryption, secure boot, and identity verification. Modern systems require TPM 2.0 for operating systems like Windows 11.[3][5][1]

### Accessing TPM Settings in BIOS

TPM settings are managed through the UEFI BIOS (PC firmware) and vary by manufacturer. To access these settings, you need to enter the BIOS setup during boot—typically by pressing F2, Delete, F1, or Fn+F2 depending on your system. The TPM option is usually found in sub-menus labeled Advanced, Security, or Trusted Computing.[6][7][1][3]

### Enabling TPM by Manufacturer

**Intel systems**: Navigate to Advanced > PCH-FW Configuration and enable "PTT" (Platform Trust Technology) or "Intel Platform Trust Technology".[5][6]

**AMD systems**: Go to Advanced > AMD fTPM Configuration and change "TPM Device Selection" to "Firmware TPM" or enable "AMD CPU fTPM".[4][5][6]

Many motherboards ship with TPM disabled by default, even though the feature is available. After enabling TPM in BIOS, save changes (typically by pressing F10) and reboot the system.[1][5][6]

### Important Considerations

When enabling TPM and Secure Boot for Windows 11, your system disk must use GPT (GUID Partition Table) format rather than MBR, and Windows must be booting in UEFI mode rather than Legacy BIOS/CSM mode. BIOS updates may reset TPM settings to defaults, so it's recommended to update BIOS firmware before enabling TPM to avoid resetting it multiple times.[2][4]

Sources
[1] Enable TPM 2.0 on your PC https://support.microsoft.com/en-us/windows/enable-tpm-2-0-on-your-pc-1fd5a332-360d-4f46-a1e7-ae6b0c90645c
[2] Activating TPM 2.0 and BIOS Update : r/Windows11 https://www.reddit.com/r/Windows11/comments/1fjsbs4/activating_tpm_20_and_bios_update/
[3] How to Enable TPM 2.0 on Dell Computers for Windows ... https://www.dell.com/support/kbdoc/en-ph/000189676/windows-10-how-to-enable-the-tpm-trusted-platform-module
[4] How to Enable Secure Boot and TPM 2.0 on ... https://www.gigabyte.com/Support/Consumer/FAQ/4395
[5] How to enable TPM in BIOS on Motherboard https://www.youtube.com/watch?v=x7mfccunwuw
[6] [Motherboard] Which ASUS model supports Windows 11 ... https://www.asus.com/support/faq/1046215/
[7] How to enable or disable TPM on BIOS https://support.lenovo.com/ph/en/solutions/ht515295-how-to-enable-or-disable-tpm-on-bios
[8] How to Enable TPM 2.0 in BIOS to Install Windows 11 ... https://h30434.www3.hp.com/t5/Desktop-Operating-Systems-and-Recovery/How-to-Enable-TPM-2-0-in-BIOS-to-Install-Windows-11-in-hp/td-p/9396455

