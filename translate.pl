#!/usr/bin/perl

use strict;
use warnings;
use XML::Simple;
use File::Find;

my (@dir, @dir2);

print "Looking for missing files... \n";

find(\&Wanted, $ARGV[0]);
sub Wanted
{
    # only operate on Perl modules
    /\.xml$/ or return;
    my $path = $File::Find::name;
    $path =~ s/$ARGV[0]//;
    push (@dir, $path);
}
find(\&Wanted2, $ARGV[1]);
sub Wanted2
{
    # only operate on Perl modules
    /\.xml$/ or return;
    my $path = $File::Find::name;
    $path =~ s/$ARGV[1]//;
    push (@dir2, $path);
}

my %second = map {$_=>1} @dir2;
my @only_in_first = grep { !$second{$_} } @dir; 


if ($#only_in_first >= 0) {
  
  print (($#only_in_first+1)." files only in $ARGV[0]: \n");
  foreach (@only_in_first) {
    print "\t$_\n";
  }
}

my %first = map {$_=>1} @dir;
my @only_in_second = grep { !$first{$_} } @dir2; 


if ($#only_in_second >= 0) {
  print (($#only_in_second+1)." files only in $ARGV[1]: \n");
  foreach (@only_in_second) {
    print "\t$_\n";
  }
}

%first = map {$_=>1} @dir;
my @in_both = grep { $first{$_} } @dir2; 

print "\nLooking for missing xml tags...\n";

sub extract_tags{
    my $xml_src=shift;
    my (@tags, %tags);
    for my $key (keys %{$xml_src}){
	$tags{$key}++;
	if (ref($xml_src->{$key}) eq 'HASH'){
	    map {$_++;} @tags{extract_tags($xml_src->{$key})}
	}
    }
    push @tags , keys %tags;
    return @tags;
}

foreach (@in_both) {
  
  my $xml_src=XMLin($ARGV[0]."/".$_);
  my @tags_in_first = extract_tags($xml_src);
  $xml_src=XMLin($ARGV[1]."/".$_);
  my @tags_in_second = extract_tags($xml_src);
  
  my %first = map {$_=>1} @tags_in_first;
  my @only_in_second = grep { !$first{$_} } @tags_in_second; 
  my %second = map {$_=>1} @tags_in_second;
  my @only_in_first = grep { !$second{$_} } @tags_in_first;
  
  if (($#only_in_first >= 0) or ($#only_in_second >= 0)) {
    print "File: $_:\n";
  
    if ($#only_in_first >= 0) {
      print ("\t".($#only_in_first+1)." tags only in $ARGV[0]: \n");
      foreach (@only_in_first) {
	print "\t\t$_\n";
      }
    }
    
    if ($#only_in_second >= 0) {
      print ("\t".($#only_in_second+1)." tags only in $ARGV[1]: \n");
      foreach (@only_in_second) {
	print "\t\t$_\n";
      }
    }
  }

}
