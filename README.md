Flash-Drive-Kiosk
=================

Scripts for running on a kiosk where users can create their own flash drives from .img files

Installation
------------

Do a `git clone https://github.com/8bitcoderookie/Flash-Drive-Kiosk.git` on your target machine.

Change the device name in both scripts to your needs. For example, if using the scripts on a Raspberry Pi change the definition `DEVICE_NAME="sdc"` to `DEVICE_NAME="sda"` in both scripts.

Using the scripts
-----------------

Plug in the original USB-Stick. Run `make-image-of-master-flashdrive.sh` to create an image file of the original. Make shure that enough space is on your block device.

Now run `copy-image-to-flashdrive.sh` which runs in an infinite loop. Plug in an emtpy USB-Stick and create a copy.

Note: The scripts do a dd copy of the block device, so make sure the size of the master USB-Stick is smaller the the size of the target USB-Sticks. Cheaper USB-Sticks tend to have less size.


