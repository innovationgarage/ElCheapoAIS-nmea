# About

ElCheapoAIS-nmea is a relay for AIS messages, sending received AIS messages, including your own position, speed etc
to land using your regular (satellite) internet connection.

# User documentation
## Hardware installation

* Ensure you have the latest version of the TinyTracker software on a USB stick attached to the USB port next to the network port.
* Connect the A, B and GND screw headers to an NMEA 0183 output on your AIS or NMEA hub
* Connect the USB cable to a USB charger
* Optionally connect a network cable

## Firewall configuration

You need to open outgoing tcp traffic to the ports 1026 and 1024 to elcheapoais.innovationgarage.tech (93.188.234.96).

## Default configuration

* NMEA bus
  * 38400 baud, 8bit, no flow control, 1 stop bit (8N1).

* AIS downsampling
  * Lowest of a total of 100 messages / sec or 10 messages / sec / mmsi.

# Production documentation
## Generating a USB software image

* Download the latest Armbian image and write it to a USB memory using dd.
* Boot an OrangePi using this USB with the serial port connected to a PC.
* Log in, then clone and install this repo:


    ```
    git clone --branch dbus-0.1 https://github.com/innovationgarage/ElCheapoAIS-nmea.git
    cd ElCheapoAIS-nmea
    ./install.sh --branch=dbus-0.1
    ```
    
Note that you do not need to make a full image of the USB stick when making copies for the copy to boot - it is enough to copy the files to a new filesystem (on a lone partition), as long as you update rootfs in /boot/armbianEnv.txt to point to /dev/sda.

## Installing the bootloader on a device
OrangePI is not able to boot from USB by default. To enable this you have to [write a copy of the u-boot boot loader to the on-board NOR-flash](https://forum.armbian.com/topic/8111-orange-pi-zero-plus-spi-nor-flash-anyone-know-how-to-configure-for-booting/?tab=comments#comment-64373).
