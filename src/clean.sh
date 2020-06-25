rm -rf /mnt/test1/big_file

umount /mnt/test1
umount /mnt/test2

rm -rf /mnt/test{1..2}

yes | lvremove FIT_lv1
yes | lvremove FIT_lv2

yes | vgremove FIT_vg

mdadm --stop /dev/md{0..1};

losetup -D;
rm -rf disk*;

ls /dev/ | grep loop;



# Detach loop device or all devices:
# ■ losetup -d /dev/loop0
# ■ losetup -D
# Stop software raid:
# ■ mdadm --stop /dev/md0
# Remove logical volume
# ■ lvremove /dev/vgtest/lvtest
# Remove volume group
# ■ vgremove vgtest

# Remove pv group
# ■ pvremove /dev/loop0
