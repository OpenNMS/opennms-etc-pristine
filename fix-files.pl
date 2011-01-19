#!/usr/bin/perl -w

use Cwd 'abs_path';
use File::Copy;
use File::Find;

my $DEBIAN = 0;
if (grep { $_ eq "-d" } @ARGV) {
	print "- using Debian mode\n";
	$DEBIAN = 1;
	shift(@ARGV);
} else {
	print "- using RPM mode\n";
}

my $FILES = \@ARGV;

my $MAPPINGS = {
	'@display.version@'                 => { rpm => 'FIXME',                        debian => 'FIXME' },
	'@install.bin.dir@'                 => { rpm => '/opt/opennms/bin',             debian => '/usr/share/opennms/bin' },
	'@install.controllerlogs.dir@'      => { rpm => '/opt/opennms/logs/controller', debian => '/var/log/opennms/controller' },
	'@install.daemonlogs.dir@'          => { rpm => '/opt/opennms/logs/daemon',     debian => '/var/log/opennms/daemon' },
	'@install.database.admin.user@'     => { rpm => 'postgres',                     debian => 'postgres' },
	'@install.database.admin.password@' => { rpm => '',                             debian => '' },
	'@install.database.driver@'         => { rpm => 'org.postgresql.Driver',        debian => 'org.postgresql.Driver' },
	'@install.database.name@'           => { rpm => 'opennms',                      debian => 'opennms' },
	'@install.database.user@'           => { rpm => 'opennms',                      debian => 'opennms' },
	'@install.database.password@'       => { rpm => 'opennms',                      debian => 'opennms' },
	'@install.dir@'                     => { rpm => '/opt/opennms',                 debian => '/usr/share/opennms' },
	'@install.etc.dir@'                 => { rpm => '/opt/opennms/etc',             debian => '/etc/opennms' },
	'@install.rrdtool.bin@'             => { rpm => '/usr/bin/rrdtool',             debian => '/usr/bin/rrdtool' },
	'@install.share.dir@'               => { rpm => '/opt/opennms/share',           debian => '/usr/share/opennms/share' },
	'@install.webapplogs.dir@'          => { rpm => '/opt/opennms/logs/webapp',     debian => '/var/log/opennms/webapp' },
	'/opt/opennms'                      => { rpm => undef,                          debian => '/usr/share/opennms' },
	'/opt/opennms/etc'                  => { rpm => undef,                          debian => '/etc/opennms' },
	'/opt/opennms/logs'                 => { rpm => undef,                          debian => '/var/log/opennms' },
	'/opt/opennms/share'                => { rpm => undef,                          debian => '/usr/share/opennms/share' },
	'/opt/opennms/share/rrd'            => { rpm => undef,                          debian => '/usr/share/opennms/share/rrd' },
	'java.lang.Integer..8180'           => { rpm => undef,                          debian => 'java.lang.Integer">8280' },
};

if (@$FILES == 0) {
	find(\&wanted, abs_path('etc'));
}

for my $file (@$FILES) {
	print "- transforming $file\n";
	open (FILEIN, "$file") or die "unable to read from $file: $!\n";
	open (FILEOUT, ">$file.fixed") or die "unable to write to $file.fixed: $!\n";
	while (my $line = <FILEIN>) {
		$line = transform_line($file, $line);
		print FILEOUT $line;
	}
	close (FILEOUT);
	close (FILEIN);
	move("$file.fixed", "$file");
}

sub transform_line {
	my $file = shift;
	my $line = shift;
	for my $key (reverse sort keys %$MAPPINGS) {
		my $value = ($DEBIAN? $MAPPINGS->{$key}->{'debian'} : $MAPPINGS->{$key}->{'rpm'});
		if (defined $value) {
			$key =~ s/\@/\[\@\]/g;
			$line =~ s/${key}/${value}/g;
		}
	}
	return $line;
}

sub wanted {
	if (-f $File::Find::name) {
		push(@$FILES, $File::Find::name);
	} else {
		# print "not a file: $File::Find::name\n";
	}
}

