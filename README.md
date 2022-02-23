winkeyer_server
===============

This is a UDP server that allows operation of the K1EL Winkeyer USB with any Linux program with UDP keyer capability. It works in the same way as the popular cwdaemon. The server expands the usability of this excellent product to all Linux programs with UDP keyer capability, including the [TLF contest logger](https://tlf.github.io/) by PA0R.

# Installation

Compiling and installation requires the Free Pascal compiler. The simplest method is to download the repository ZIP file, unpack it into any convenient directory, then navigate there in a Terminal window. Install the compiler, then compile. For example, in Ubuntu Linux:

`sudo apt install lazarus`

`make`

`sudo make install`

# Usage

To start the application, open a Terminal window in any directory and type:

`winkeyer_server`

Check that the USB address for the Winkeyer is entered correctly. /dev/ttyUSB0 is the default, but yours may be at /dev/ttyUSB1 or another address. If you're unsure, go back to the Terminal and enter:

`ls -l /dev/serial/by-id`

which should list the connected serial devices and their direct addresses.

Once you've found the keyer and put its correct address into the window, click the button to start the keyer connection, and confirm in the Debug window that it's running (it should list the Winkeyer firmware version but no error messages). Finally, click to start the server. You should now be able to start TLF or any other program that expects to find cwdaemon on Port 6789. If your software uses a different port, just put that into the appropriate box and restart the server.
