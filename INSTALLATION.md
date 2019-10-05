# Remote Server for Juneday's Presentation Assistant

# Introduction

# Starting the server

```
./start_server.sh
```

## Server

## Dispatcher

# Servers (or server backends)

## swinput

Only Linux is supported.

### Download and build source code

```
curl -LJO https://github.com/hesa/swinput/archive/master.zip
unzip swinput-master.zip 
cd swinput-master
make
```

### Install swinput

Instal the kernel modules and load them in to the kernel. Make sure that your groups can read/write to the device.

```
sudo make install
sudo modprobe swkeybd
sudo chgrp $(id -gn) /dev/swkeybd
sudo chmod g+rw /dev/swkeybd
```

*Note: Swinput comes with another kernel module called swmouse - which as you might have figured out provides a virtual mouse*

### Use swinput

You can try out swinput by issuing the following command:
```
echo "a" > /dev/swkeybd
```

You should see an 'a' in your terminal as if you've pressed 'a' yourself.


# Dispatchers
