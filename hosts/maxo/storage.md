# Maxo ZFS provisioning

Run this once on `maxo` before applying the NixOS configuration. These commands
destroy existing contents on the three listed disks. Verify every `/dev/disk/by-id`
path with `ls -l /dev/disk/by-id/` first.

```bash
sudo zpool create -f -o ashift=12 \
  -O acltype=posixacl -O xattr=sa -O dnodesize=auto \
  -O compression=zstd -O normalization=formD \
  -O atime=off \
  tank mirror \
  /dev/disk/by-id/ata-WDC_WD20SDRW-11VUUS0_WD-WX72A71CZKAJ \
  /dev/disk/by-id/ata-WDC_WD20SDRW-11VUUS0_WD-WXW2A61N5SFC

sudo zpool create -f -o ashift=12 \
  -O acltype=posixacl -O xattr=sa -O dnodesize=auto \
  -O compression=zstd -O normalization=formD \
  -O atime=off \
  data \
  /dev/disk/by-id/ata-WDC_WD40NMZW-11GX6S1_WD-WX61DB6HA6SH

sudo zfs create tank/ente
sudo zfs create tank/nas
sudo zfs create tank/backups

sudo zfs create data/media
sudo zfs create data/docker
```

The NixOS host configuration imports `tank` and `data` at boot, mounts the five
datasets at their standard paths, and enables periodic scrubs. The Docker
daemon stores its state in `/data/docker`.

Check the result before switching:

```bash
sudo zpool status
sudo zfs list
sudo nixos-rebuild switch --flake /etc/nixos#maxo
```