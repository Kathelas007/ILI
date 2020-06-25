
#!/bin/bash


# *******************************************************************************

mng_output () {

	if [ 0 -eq "$1" ]
	then
		echo "$2"
	else
		echo "$3"
		exit -1
	fi
}


# *******************************************************************************
echo

# *** 1 Create 4 loop of 200MB devices which supplement real storage devices.
for p in {0..3};
do
	{
		dd if=/dev/zero of=disk$p bs=200M count=1;
		losetup "loop$p" "disk$p";
	} &>/dev/null;

	mng_output $? "Loop device number $p created" "Losetup by device number $p failed";
done
echo;


# *** 2 Create RAID1 0, 1 loop devices,  RAID0 on 2, 3 loop devices.
yes | mdadm --create /dev/md1 --level=mirror --raid-devices=2 /dev/loop0 /dev/loop1 &>/dev/null;
mng_output $? "Physical volume RAID1 successfully created" "Creating of /dev/md1 failed"

yes | mdadm --create /dev/md0 --level=mirror --raid-devices=2 /dev/loop2 /dev/loop3 &>/dev/null;
mng_output $? "Physical volume RAID0 successfully created" "Creating of /dev/md0 failed"
echo;

# *** 3 Create volume group on top of 2 RAID devices.
{
vgcreate FIT_vg /dev/md1 /dev/md0;
}&>/dev/null
mng_output $? "Volume group FIT_vg successfully created" "Creating of /dev/md0 failed"
echo;

# *** 4 In vol gr create log vol 100MB FIT_lv1, FIT_lv2
for i in {1..2};
do
	lvcreate /dev/FIT_vg -n "FIT_lv$i" -L100M &>/dev/null;
	mng_output $? "Logical volume FIT_lv$i successfully created" "Creating of FIT_lv$i failed"
done;
echo;


# *** 5 Create EXT4 filesystems on ​ FIT_lv1​ logical volume.
mkfs -t ext4 /dev/FIT_vg/FIT_lv1 &>/dev/null;
mng_output $? "EXT4 filesystem on FIT_lv1 successfully created" "Creating of EXT4 filesystem on FIT_lv1 failed"


# *** 6 Create XFS filesystems on ​ FIT_lv2​ logical volume
mkfs -t xfs /dev/FIT_vg/FIT_lv2 &>/dev/null;
mng_output $? "XFS filesystem on FIT_lv2 successfully created" "Creating of XFS filesystem on FIT_lv2 failed"
echo;

# *** 7 Mount ​ FIT_lv1​ to ​ /mnt/test1​ and ​ FIT_lv2​ to ​ /mnt/test2​ directories.
for i in {1..2};
do
	{ 
		mkdir "/mnt/test$i";
	  	mount "/dev/FIT_vg/FIT_lv$i" "/mnt/test$i";
	} &>/dev/null;
	mng_output $? "Logical volume FIT_lv$i mounted to /mnt/test1$i" "Mounting of FIT_lv$i failed"
done;
echo;

# *** 8 Resize filesystem on ​ FIT_lv1​ to claim all available space in the volume group
{
umount /mnt/test1
lvextend /dev/FIT_vg/FIT_lv1 -l +100%FREE;
e2fsck -f /dev/FIT_vg/FIT_lv1;
resize2fs /dev/FIT_vg/FIT_lv1;
mount "/dev/FIT_vg/FIT_lv1" "/mnt/test1";
};

line=$(df -h | grep FIT_lv1)
if [[ $ver == *"279"* ]]; then
    echo "FIT_lv1 resized."
else
    echo "FIT_lv1 not resized."
fi



# *** 9 Create 300MB file ​ /mnt/test1/big_file ​ command
	# Create a checksum of the file ​ /mnt/test1/big_file ​ using tool `​ sha512sum’.
	dd if=/dev/urandom of=/mnt/test1/big_file bs=300M count=1 &>/dev/null;
	echo "Checksum of big file:";
	sha512sum /mnt/test1/big_file;
	echo;


# *** 10 Emulate faulty disk replacement:
	# a Create 5th loop device representing new disk (200MB)
	{	
		dd if=/dev/zero of=diskN bs=200M count=1;
		losetup /dev/loop4 diskN;
	} &>/dev/null;
	mng_output $? "New loop device created" "Losetup of new loop device failed";

	# b Replace one of the RAID1 loop devices with the new loop device
	mdadm --manage /dev/md1 --fail /dev/loop0 &>/dev/null;
	mng_output $? "Loop device number 0 in RAID1 labeled as failed" "Error";

	sleep 4;			 # it takes time to label /dev/loop0 as failed

	mdadm --manage /dev/md1 --remove /dev/loop0 &>/dev/null;
	mng_output $? "Loop device number 0 in RAID1 removed" "Error";

	mdadm --manage /dev/md1 --add /dev/loop4 &>/dev/null;
	mng_output $? "New loop device added to RAID1" "Adding new loop device to RAID1 failed";


	# c Verify the successful recovery of RAID using ​ mdadm​ tool or file ​ /proc/mdstat
	ver=$(cat /proc/mdstat | grep md1);

	if [[ $ver == *"loop4"* ]] && [[ $ver == *"loop1"* ]] && [[ $ver == *"active"* ]] && [[ $ver != *"loop0"* ]]; then
		echo "RAID1 recovered.";
	else
		echo "RAID1 not recovered";
		exit -1;
	fi

	
