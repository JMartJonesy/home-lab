1. Download minimal [NixOS ISO](https://nixos.org/download/)
2. Flash ISO to usb drive
    a. For Windows use [Rufus](https://rufus.ie/)
    b. For Linux use [UNetbootin](https://unetbootin.github.io/)
3. Disable secure boot in bios
4. Boot into usb
5. Setup internet connection
	a. Plug in ethernet cable
	b. Setup wifi
		1. Start wpa_supplicant 
		```bash
			sudo systemctl start wpa_supplicant
		```
		2. Start cli 
		```bash
		   wpa_cli
		```
		3. Setup your network and connect
		```
		   add_network        
		   set_network 0 ssid "<WIFI SSID>"        
		   set_network 0 psk "<WIFI PASSWORD>"        
		   set_network 0 key_mgmt WPA-PSK        
		   enable_network 0        
		   quit
		```  
6.  Move to /tmp folder and setup disko config
```bash 
cd /tmp
```
7. Download disko nix config 
```bash
curl https://raw.githubusercontent.com/JMartJonesy/dotfiles/refs/heads/main/setup-guides/framework16/disko.nix -o /tmp/disko.nix
```
8. Find drive name and update disko.nix 
```bash
lsblk
```
```nix
device = /dev/<YOUR DRIVE NAME HERE>
```
9. Run disko to setup drive 
```bash
sudo nix run github:nix-community/disko -- --mode disko /tmp/disko.nix
```
10. Enter your encryption key when prompted (Save this somewhere like 1Password)
11. Confirm everything was mounted as expected 
```bash
mount | grep /mnt
```
12. Generate your nix configuration files excluding the filesystem portion as we will use disko.nix for that 
```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```
13. Move disko.nix to /mnt/etc/nixos
```bash
sudo mv /tmp/disko.nix /mnt/etc/nixos
cd /mnt/etc/nixos
```
14. Update configuration.nix imports to include disko and disko.nix 
```nix
imports = [
   # Include the results of the hardware scan.
   ./hardware-configuration.nix
   ./disko.nix
];
```
15. (Optional) Enable networkmanager in your configuration.nix otherwise you will have no wifi on reboot
```nix
networking.networkmanager.enable = true;
```
16. Add user to configuration.nix there should already be a block you can update with the following 
```nix
users.users.jmartjonesy = {
	isNormalUser = true;
	extraGroups = [ "networkmanager" "wheel" ];
};
```
17. Install nixos on your drive 
```bash
sudo nixos-install
```
18. Enter root password when prompted
19. Set password for the user you created in step 16 
```bash
sudo nixos-enter --root /mnt -c 'passwd jmartjonesy'
```
20. Reboot and login as your user
```bash
reboot
```
21. (Optional) Setup wifi but this time with nmcli  
```bash
nmcli radio wifi on
nmcli dev wifi connect network-ssid password "network-password"
```
22. Confirm systemd-boot is the current bootloader as this is required to steup lanzaboote for Secure Boot
```bash 
bootctl status
```
23. Create Secure Boot keys
```bash
sudo sbctl create-keys
```
24. Add pgks.git to your configuration.nix
25. Clone dotfiles repo locally
```bash
cd
git clone https://github.com/JMartJonesy/dotfiles.git
```
26. Replace `/etc/nixos` with `~/dotfiles/nixos`
```bash
cd /etc/nixos
sudo mkdir backup
sudo mv ./* backup
sudo cp -r ~/dotfiles/nixos/* .
```
27. Create new folder for this machine in /etc/nixos/hosts and copy your `configuration.nix` `disko.nix` and `hardware-configuration.nix` into this new folder
```bash
sudo mkdir /etc/nixos/hosts/<NEW MACHINE HOSTNAME>
sudo cp configuration.nix disko.nix harware-configuration.nix /etc/nixos/<NEW MACHINE HOSTNAME>
```
28. Update flake.nix with new nixosConfiguration for your machine
```nix
# EXAMPLE:
<NEW MACHINE HOSTNAME> = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            # Pass individual inputs by name to avoid recursion
            inherit
              disko
              nixos-hardware
              lanzaboote
              stylix
              kickstart-nixvim
              # ... and any other imports you want on this machine
              ;
          };
          modules = [
            ./hosts/<NEW MACHINE HOSTNAME>/configuration.nix
            home-manager.nixosModules.home-manager
          ];
        };
```
29. Set your hostname in your configuration.nix file
```nix
networking.hostName = "<NEW MACHINE HOSTNAME>";
```
30. Checkout kickstart.nxivim into ~/Projects
```bash
cd ~/Projects
git clone https://github.com/JMartJonesy/kickstart.nixvim.git
git checkout -b jmartjonesy
```
31. Rebuild nixos configuration with your new machine hostname (see available hosts in flake.nix)
```bash
sudo nix run nixos-rebuild switch --flake /etc/nixos#<NEW MACHINE HOSTNAME>
```
32. Check that your machine is ready for Secure Boot (It is expected that `/boot/EFI/nixos/kernel*.efi` files are not signed, everything else should be signed)
```bash
sudo sbctl verify
```
32. Reboot into BIOS
33. Enable Secure boot (Framework laptops require a slightly different setup see [here](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md#part-2-enabling-secure-boot) for details)
32. Enroll your keys
```bash
sudo sbctl enroll-keys --microsoft
```
34. Reboot and confirm nixos boots. You will need to enter your encryption key set in step 10 every time you boot to unlock your drive
35. (Optional) Register your fingerprint (Need to have `fprintd` installed)
```bash
sudo fprintd-enroll $USER
```

REFERENCES:
- https://github.com/nix-community/disko/blob/master/docs/quickstart.md
- https://haseebmajid.dev/posts/2024-07-30-how-i-setup-btrfs-and-luks-on-nixos-using-disko/?utm_source=perplexity
- https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
