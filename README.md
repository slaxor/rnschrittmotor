RNSchrittmotor
--------------
http://github.com/slaxor/rnschrittmotor

DESCRIPTION:
------------
This is a convenience lib for the Stepper-Controller board from
[robotikhardware shop](http://www.shop.robotikhardware.de/shop/catalog/product_info.php?products_id=173 "Robotikhardware Shop RN-Schrittmotor"). It follows this
[API-Doc](http://www.robotikhardware.de/download/rnschrittmotor.pdf "RN-Schrittmotor API-Doc")

SYNOPSIS:
---------
Use it like this:

    s = RNSchrittmotor.new('/dev/ttyUSB0', 9600)
    s.read_version
    s.set_crc_mode(RNSchrittmotor::CRCON)
    s.step!(RNSchrittmotor::BOTH, 400)
    # RTFS for more

REQUIREMENTS:
-------------
It currently depends on serialport

INSTALL:
--------
    gem install rnschrittmotor

LICENSE:
--------
© 2010 Sascha Teske <sascha.teske@microprojects.de>
General Public License version 3 or later (in this folder gpl_v3.txt)

