{
  description = "J-Stash Nixos Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
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
              ;
          };
          modules = [
            ./configuration.nix
          ];
        };
      };
    };
}
