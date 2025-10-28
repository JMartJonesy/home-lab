{
  description = "J-Stash Nixos Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    /*
      sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      kickstart-nixvim = {
        url = "path:/home/jmartjonesy/Projects/kickstart.nixvim";
      };
      stylix = {
        url = "github:danth/stylix";
      };
    */
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      /*
        sops-nix,
        home-manager,
        kickstart-nixvim,
        stylix,
      */
      ...
    }@inputs:
    {
      nixosConfigurations = {
        j-stash = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            # Pass individual inputs by name to avoid recursion
            inherit
              disko
              /*
                lanzaboote
                kickstart-nixvim
                stylix
              */
              ;
          };
          modules = [
            ./hosts/framework16/configuration.nix
            /*
              sops-nix.nixosModules.sops
              home-manager.nixosModules.home-manager
            */
          ];
        };
      };
    };
}
