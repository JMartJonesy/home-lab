{
  pkgs,
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "j-stash";

  # Enable mdadm for RAID
  boot.swraid.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  users.users.jmartjonesy = {
    isNormalUser = true;
    description = "JMartJonesy Biznatch";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
  ];

  time.timeZone = "America/Los_Angeles";
  system.stateVersion = "24.11";
}
