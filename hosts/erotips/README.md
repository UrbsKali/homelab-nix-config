# Erotips: retired node inventory

Erotips is the old media and Docker node being replaced by `maxo`.

## System

- NixOS 25.11, kernel `6.12.93`
- Pegatron 2AB5 motherboard
- Intel Core i7-2600, 8 threads
- 14 GiB RAM DDR3
- Static address `192.168.1.44/24`, gateway `192.168.1.1`
- Root filesystem on `/dev/sda`, with `/dev/sdb` and `/dev/sdc` combined in LVM

## Storage

The two disks below formed the LVM-backed Docker download volume:

- `/dev/sda`: Hitachi HDS723015BLA642, 1.5 TB, 49,138 power-on hours
- `/dev/sdb`: TOSHIBA MQ01ABD100, 1 TB, 36,527 power-on hours
- `/dev/sdc`: 111.8 GB system disk, with `/` on `sdc1` and swap on `sdc2`

The LVM volume was mounted at:

`/home/dvb/docker/volumes/media-stack_torrent-downloads/_data`

## SMART observations

Both disks reported `PASSED`, with zero reallocated and pending sectors at the time of capture. They should not be treated as healthy production storage without further testing:

- The Hitachi reported 12 ATA errors, including uncorrectable reads (`UNC`) and write-protect errors (`WP`), plus a very high command-timeout raw counter.
- The Toshiba reported 9 ATA errors, all `ICRC, ABRT`, and 9 UDMA CRC errors, which points to a historical cabling, power, or controller path problem.
- The Hitachi extended self-test was interrupted at 90% by a host reset.

The supplied SMART capture is summarized above. Run `sudo smartctl -x /dev/sda` and `sudo smartctl -x /dev/sdb` before reusing either disk.

## Services

- Docker with data rooted at `/home/dvb/docker`
- The shared tunnel service using the default `tunnel/*` SOPS secrets
- Media firewall ports: `5055`, `8096`, `7878`, `8989`, `5080`, and `9696`

`maxo` is intended to take over the Docker and tunnel roles; migrate application data separately before decommissioning this host.