=== 0.6.1 / 2011/11/20

* Add to_h method for core classes
* Add to_pacp/to_file method for packet class

=== 0.6.0 / 2011-11-13

* update deps
* added support for unified2 extra data
* refactor Unified2#read & Unified2#watch
* Interrupt now returns file position
* updated spec for legacy u2 and current format changes
* events can now have multiple packets
* bug fixes and documentation

=== 0.5.4 / 2011-06-27

* update packetfu ~> 1.1
* update bindata ~> 1.4
* update hexdump ~> 0.2
* remove pcaprb dep

=== 0.5.3 / 2011-03-24

* remove unnecessary file (untitled.rb)

=== 0.5.2 / 2011-03-24

* Add payload checksum support

=== 0.5.1 / 2011-03-21

* fixed exception when watching an empty unified2 log file
* renamed a few Event#ip_header hash keys

=== 0.5.0 / 2011-03-18

* major refactoring
* Added eth, ip, udp, icmp, and TCP header support
* Added basic specs and fully documented the source

=== 0.4.0 / 2011-03-14

* added checksum support for sensor

=== 0.3.2 / 2011-03-14

* fix broken example scripts

=== 0.3.1 / 2011-03-14

* Removed gibbler in favor of custom Event#checksum method due to datamapper issues.

=== 0.3.0 / 2011-03-13

* Added checksum support for event objects
* Fixed example signature filename typo

=== 0.2.1 / 2011-03-12

* minor bug fixes and typos

=== 0.2.0 / 2011-03-09

* Removed signature references
* updated example for mysql adaptor

=== 0.1.1 / 2011-03-09

* minor documentation fixes
* added proper example files

=== 0.1.0 / 2011-03-08

* Initial release:
