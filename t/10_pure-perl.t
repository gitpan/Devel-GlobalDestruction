use strict;
use warnings;
use FindBin qw($Bin);
use Config;
use IPC::Open2;
use File::Glob 'bsd_glob'; # support spaces in names unlike glob()

# rerun the tests under the assumption of pure-perl

# for the $^X-es
$ENV{PERL5LIB} = join ($Config{path_sep}, @INC);
$ENV{DEVEL_GLOBALDESTRUCTION_PP_TEST} = 1;

my $this_file = quotemeta(__FILE__);

my @tests = grep { $_ !~ /${this_file}$/ } bsd_glob("$Bin/*.t");
print "1..@{[ scalar @tests ]}\n";

sub ok ($$) {
  print "not " if !$_[0];
  print "ok";
  print " - $_[1]" if defined $_[1];
  print "\n";
}

for my $fn (@tests) {
  # this is cheating, and may even hang here and there (testing on windows passed fine)
  # if it does - will have to fix it somehow (really *REALLY* don't want to pull
  # in IPC::Cmd just for a fucking test)
  # the alternative would be to have an ENV check in each test to force a subtest
  open2(my $out, my $in, $^X, $fn );
  while (my $ln = <$out>) {
    print "   $ln";
  }

  wait;
  ok (! $?, "Exit $? from: $^X $fn");
}

