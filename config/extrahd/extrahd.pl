#!/usr/bin/perl
#
# IPFire Scripts
#
# This code is distributed under the terms of the GPL
#
# (c) The IPFire Team
#

use strict;
# enable only the following on debugging purpose
# use warnings;

require '/var/ipfire/general-functions.pl';
require "${General::swroot}/lang.pl";
require "${General::swroot}/header.pl";

my %extrahdsettings = ();
my $ok = "true";
my @devices = ();
my @deviceline = ();
my $deviceentry = "";
my $devicefile = "/var/ipfire/extrahd/devices";
my $fstab = "/var/ipfire/extrahd/fstab";

### Values that have to be initialized
$extrahdsettings{'PATH'} = '';
$extrahdsettings{'FS'} = '';
$extrahdsettings{'DEVICE'} = '';
$extrahdsettings{'ACTION'} = '';

open( FILE, "< $devicefile" ) or die "Unable to read $devicefile";
@devices = <FILE>;
close FILE;

############################################################################################################################
############################################################################################################################

print "$ARGV[0] $ARGV[1]";

if ( "$ARGV[0]" eq "mount" ) {
	system("/bin/cp -f /etc/fstab $fstab");

	foreach $deviceentry (sort @devices)
	{
		@deviceline = split( /\;/, $deviceentry );
		if ( "$ARGV[1]" eq "$deviceline[2]" ) {
			print "Insert /dev/$deviceline[0] ($deviceline[1]) --> $deviceline[2] into /etc/fstab!\n";
			unless ( -d $deviceline[2] ) { system("/bin/mkdir -p $deviceline[2] && chmod 0777 $deviceline[2]"); }
			open(FILE, ">>$fstab");
			print FILE "/dev/$deviceline[0]\t$deviceline[2]\t$deviceline[1]\tdefaults\t0\t0\n";
			close(FILE);
		}
	}

	system("/bin/cp -f $fstab /etc/fstab");
	if ( `/bin/mount -a` ) {
		exit(0);
	} else {
		exit(1);
	}

} elsif ( "$ARGV[0]" eq "umount" ) {
	system("/bin/umount $ARGV[1]");
	if ( ! `/bin/mount | /bin/fgrep $ARGV[1]` ) {
		system("/bin/cp -f /etc/fstab $fstab");
		system("/bin/fgrep -v $ARGV[1] <$fstab >/etc/fstab");
		print "Succesfully umounted $ARGV[1].\n";
		exit(0);
	} else {
		print "Can't umount $ARGV[1].\n";
		exit(1);
	}

} else {
	print "Usage: $0 (mount|umount) mountpoint\n";
}

############################################################################################################################
############################################################################################################################
