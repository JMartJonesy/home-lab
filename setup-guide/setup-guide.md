1. Download minimal [NixOS ISO](https://nixos.org/download/)
2. Flash ISO to usb drive
    a. For Windows use [Rufus](https://rufus.ie/)
    b. For Linux use [UNetbootin](https://unetbootin.github.io/)
3. Boot into usb
4. Move to /tmp folder and setup disko config
```bash 
cd /tmp
```
5. Download disko nix config 
```bash
curl https://raw.githubusercontent.com/JMartJonesy/home-lab/refs/heads/main/setup-guide/disko.nix -o /tmp/disko.nix
```
6. Find drive name(s) and update disko.nix 
```bash
lsblk
```
```nix
device = /dev/<YOUR DRIVE NAME HERE>
```
7. Run disko to setup drive 
```bash
sudo nix run github:nix-community/disko -- --mode disko /tmp/disko.nix
```
8. Confirm everything was mounted as expected 
```bash
mount | grep /mnt
```
9. Generate your nix configuration files excluding the filesystem portion as we will use disko.nix for that 
```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```
10. Move disko.nix to /mnt/etc/nixos
```bash
sudo mv /tmp/disko.nix /mnt/etc/nixos
cd /mnt/etc/nixos
```
11. Update configuration.nix imports to include disko and disko.nix
```nix
imports = [
   # Include the results of the hardware scan.
   ./hardware-configuration.nix
   ./disko.nix
];
```
12. Enable ssh in configuration.nix
```nix
services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
};
```
13. Add user to configuration.nix there should already be a block you can update with the following 
```nix
users.users.jmartjonesy = {
	isNormalUser = true;
	extraGroups = [ "networkmanager" "wheel" ];
};
```
14. Install nixos on your drive 
```bash
sudo nixos-install
```
15. Enter root password when prompted
16. Set password for the user you created in step 16 
```bash
sudo nixos-enter --root /mnt -c 'passwd jmartjonesy'
```
17. Reboot and login as your user
```bash
reboot
```
18. Add pgks.git to your configuration.nix
19. Clone home-lab repo
```bash
cd
git clone https://github.com/JMartJonesy/home-lab.git
```
20. Replace `/etc/nixos` with `~/dotfiles/nixos`
```bash
cd /etc/nixos
sudo mkdir backup
sudo mv ./* backup
sudo cp -r ~/dotfiles/nixos/* .
```
21. Checkout kickstart.nxivim into ~/Projects
```bash
cd ~/Projects
git clone https://github.com/JMartJonesy/kickstart.nixvim.git
git checkout -b jmartjonesy
```
22. Rebuild nixos configuration
```bash
sudo nix run nixos-rebuild switch --flake /etc/nixos#j-stash
```

REFERENCES:
- https://github.com/nix-community/disko/blob/master/docs/quickstart.md
