#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;

my $warn = 80;
my $crit = 90;

GetOptions(
  "w|warning=i"  => \$warn,
  "c|critical=i" => \$crit,
);

open my $fh, '<', '/proc/meminfo' or do {
  print "UNKNOWN - Cannot read /proc/meminfo\n";
  exit 3;
};

my %m;
while (<$fh>) {
  if (/^(\w+):\s+(\d+)/) {
    $m{$1} = $2;
  }
}
close $fh;

my $total = $m{MemTotal} || 0;
my $available = $m{MemAvailable} || 0;

if ($total <= 0) {
  print "UNKNOWN - Cannot determine memory\n";
  exit 3;
}

my $used = $total - $available;
my $used_pct = int(($used / $total) * 100 + 0.5);
my $avail_pct = 100 - $used_pct;

my $total_mb = int($total / 1024);
my $used_mb = int($used / 1024);
my $avail_mb = int($available / 1024);

my $status = "OK";
my $exit = 0;

if ($used_pct >= $crit) {
  $status = "CRITICAL";
  $exit = 2;
} elsif ($used_pct >= $warn) {
  $status = "WARNING";
  $exit = 1;
}

print "$status - Memory used: ${used_pct}% (${used_mb}MB/${total_mb}MB), available: ${avail_pct}% (${avail_mb}MB) | mem_used=${used_pct}%;${warn};${crit};0;100 mem_used_mb=${used_mb}MB;;;0;${total_mb}\n";
exit $exit;
