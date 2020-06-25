# ILI - Advanced Topics of Linux Administration
## Proj1 - disk management

### Description
Prepare an executable Bash script performing the following 10 requirements (2 points each):
1. Create 4 loop devices which supplement real storage devices.   
  a. Create files of 200MB size each.  
2. Create software RAID1 on the first 2 loop devices and RAID0 on the other 2 loop
devices.  
3. Create volume group on top of 2 RAID devices.  
  a. Name the volume group ​ FIT_vg ​
4. In the volume group create 2 logical volumes of size 100MB each
  a. Name the logical volumes ​ FIT_lv1​ and ​ FIT_lv2  
5. Create EXT4 filesystems on ​ FIT_lv1​ logical volume.  
6. Create XFS filesystems on ​ FIT_lv2​ logical volume.  
7. Mount ​ FIT_lv1​ to ​ /mnt/test1​ and ​ FIT_lv2​ to ​ /mnt/test2 ​ directories.
8. Resize filesystem on ​ FIT_lv1​ to claim all available space in the volume group
  a. Verify using ​ `df -h` ​ command
9. Create 300MB file ​ /mnt/test1/big_file ​ using command​ `dd`​ command feeding it
with data from ​ /dev/urandom​ device:
  a. Create a checksum of the file ​ /mnt/test1/big_file ​ using tool ​ ` sha512sum`.
10. Emulate faulty disk replacement:
  a. Create 5th loop device representing new disk (200MB)  
  b. Replace one of the RAID1 loop devices with the new loop device
  c. Verify the successful recovery of RAID using ​ mdadm​ tool or file ​ /proc/mdstat.
