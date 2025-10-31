{
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/<DEVICE HERE>";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00"; # EFI System Partition type
              content = {
                type = "mdraid";
                name = "boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "raid1";
              };
            };
          };
        };
      };
      nvme1 = {
        type = "disk";
        device = "/dev/<DEVICE HERE>";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00"; # EFI System Partition type
              content = {
                type = "mdraid";
                name = "boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "raid1";
              };
            };
          };
        };
      };
    };
    mdadm = {
      boot = {
        type = "mdadm";
        # RAID level 1 (mirroring)
        level = 1;
        # Metadata version 1.0 places RAID metadata at END of partition
        # This is REQUIRED for UEFI boot compatibility - allows firmware to read FAT32
        metadata = "1.0";
        content = {
          type = "filesystem";
          # FAT32 (vfat) required for UEFI boot partition
          format = "vfat";
          mountpoint = "/boot";
          # umask=0077 sets restrictive permissions (only root can read/write)
          mountOptions = [ "umask=0077" ];
        };
      };
      raid1 = {
        type = "mdadm";
        # RAID level 1 (mirroring) for root filesystem
        level = 1;
        # Metadata version defaults to 1.2 (latest) for non-boot partitions
        # Version 1.2 offers better performance and places metadata at start of partition
        # Not explicitly set here, will use mdadm default (1.2)
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/";
          mountOptions = [
            # noatime: don't update access time on file reads
            # Reduces write operations, improves performance, extends SSD life
            "noatime"
          ];
        };
      };
    };
  };
}
