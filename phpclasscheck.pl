#!/usr/bin/perl

use strict;
use warnings;

my $help = <<END;

  usage : $0 [-c|-l] [-m|-p] [-v] file

      -c    check
      -l    list (default)
      -m    methods only
      -p    properties only
      -v    verbose

END

unless ( @ARGV ) { die $help }

use Getopt::Std;
getopts('lcmpv');
our ( $opt_l , $opt_c , $opt_m, $opt_p, $opt_v );

my @FILES;

my $inputFile = $ARGV[0];
my $folder = undef;

my $fileNotFound = <<END;

  file or folder $inputFile not found

END
  
if ( -f $inputFile ) {
  push( @FILES, $inputFile );
}
elsif ( -d $inputFile ) {

  $folder = $inputFile;
  $folder =~ s|/$||;
  @FILES = find_files($folder);
}
else {
  die $fileNotFound;
}


my $cnt = 0;
my $err_cnt = 0;

# my @files;


#
# -- list methods -------------------------------------------------------------
#
  
sub list_methods {

  my @file = @_;

  my %results;
  my $lineCount = 0;
  
  print "Listing methods\n";
  my $hasAbstract = 0;
  
  foreach (@file) {

  my $abstract = '';

    $lineCount++;
    chomp;
    
    if ( /((abstract)?(\s+p\w+\s+)?function\s+\w+\(.*)/ ) {
      # remove leading spaces
      $_ =~ s/^\s+//;
      # remove end of line
      $_ =~ s/[{;]//g;

      my @buffer = split( /\s+/ , $_ );
      if ( $buffer[0] eq 'abstract') {
        $abstract = 'abstract';
        shift @buffer;
        $hasAbstract = 1 if (!$hasAbstract);
      }
      $results{$lineCount}{'abstract'} = $abstract;
      
      my $access = shift @buffer;
      my $function = join( ' ' , @buffer);
      
      $results{$lineCount}{'access'} = $access;
      $results{$lineCount}{'function'} = $function;
    }
  }

  foreach ( sort { $a <=> $b }keys %results ) {    
    if ( $hasAbstract ) {
      printf " %-4s %-8s %-9s %s\n", $_, $results{$_}{'abstract'}, $results{$_}{'access'}, $results{$_}{'function'};
    }
    else {
      printf "%-4s %-9s %s\n", $_, $results{$_}{'access'}, $results{$_}{'function'};
    }
  }
}


#
# -- list properties ----------------------------------------------------------
#
sub list_properties {

  my @file = @_;

  print "Listing properties used\n";

  my $lineCount = 0;
  my %propertyList;
  foreach my $line (@file) {
    $lineCount++;
    if ( $line =~ /this->(\w+)(?!(.*)[(])/ ) {
        $propertyList{$1}{ 'count' } = $cnt++ if ( ! $propertyList{$1} );
        push( @{$propertyList{$1}{'line'}}, $lineCount );
    }
  }

  foreach my $param ( sort { $propertyList{$a}{ 'count' } <=> $propertyList{$b}{ 'count' } } keys %propertyList ) {
    printf "  %-20s used on line ", $param;
    my $lines = '';
    foreach ( @{$propertyList{$param}{'line'}} ) {
      $lines .= "$_, ";
    }
    $lines =~ s/,\s$//;
    print "$lines\n";
  }
}

#
# -- check method parameters declarations -------------------------------------
#
my $class = '';

sub check_method_parameters_declaration {

  my @file = @_;

  print "  $class Checking method parameters declarations ... ";

  my $lineCount = 0;
  my %parameterList;
  foreach my $line (@file) {
    $lineCount++;
    if ( $line =~ /p\w+\s+function/ ) {

      my @list = $line =~ /(\$\w+)/g;
      foreach my $item (@list) {

        $parameterList{$item}{ 'count' } = $cnt++ if ( ! $parameterList{$item} );
        push( @{$parameterList{$item}{'line'}}, $lineCount );
        
      }
    }
  }
  unless (%parameterList) {
    print "  no parameter found\n";
  }


  foreach my $param ( sort { $parameterList{$a}{ 'count' } <=> $parameterList{$b}{ 'count' } } keys %parameterList ) {
    my $output = sprintf "\n    found parameter %-15s", $param;
    $param =~ s/\$//;

    my $lineCount = 0;
    my $found = 0;
    foreach (@file) {
      $lineCount++;
      if ( /(public|protected|private)\s+\$$param/ ) {
        printf "$output declared as %-15s on line %s", $param, $lineCount if ($opt_v);
        $found = 1;
        last;
      }
    }

    if (!$found) {
      $err_cnt++;
      print "$output NOT DECLARED, used on line ";  
      my $lines = '';
        foreach ( @{$parameterList{"\$$param"}{'line'}} ) {
        $lines .= "$_, ";
      }
      $lines =~ s/,\s$//;
      print "$lines";
    }
  }
#   print "debug : \$err_cnt -> $err_cnt\n";
  print "\n" if (( $err_cnt > 0 ) or ( $opt_v )) ;
}


#
# -- check properties declarations --------------------------------------------
#
sub check_properties_declaration {

  my @file = @_;

  print "  Checking properties declarations\n";

  my $lineCount = 0;
  my %propertyList;
  foreach my $line (@file) {
    $lineCount++;
    if ( $line =~ /this->(\w+)(?!(.*)[(])/ ) {

        $propertyList{$1}{ 'count' } = $cnt++ if ( ! $propertyList{$1} );
        push( @{$propertyList{$1}{'line'}}, $lineCount );
    }
  }
  unless (%propertyList) {
    print "  no parameter found\n";
  }  


  foreach my $param ( sort { $propertyList{$a}{ 'count' } <=> $propertyList{$b}{ 'count' } } keys %propertyList ) {
    my $output = sprintf "    found property %-15s", $param;

    my $lineCount = 0;
    my $found = 0;
    foreach (@file) {
      $lineCount++;
      if ( /((public|protected|private)\s+\$$param)/ ) {
        printf "$output  declared as %-30s on line %s\n", $1, $lineCount if ($opt_v);
        $found = 1;
        last;
      }
    }

    if (!$found) {
      $err_cnt++;
      print "$output  NOT DECLARED, used on line ";  
      my $lines = '';
      foreach ( @{$propertyList{$param}{'line'}} ) {
        $lines .= "$_, ";
      }
      $lines =~ s/,\s$//;
      print "$lines\n";
    }
  }
}

my $ARGS = '';

if ((!$opt_c) and (!$opt_l)) {
  $ARGS .= 'l';
}

if ((!$opt_m) and !($opt_p)) {
  $ARGS .= 'pm';
}

if ( $opt_l ) {
  $ARGS .= 'l';
}
if ( $opt_c ) {
  $ARGS .= 'c';
}
if ( $opt_m ) {
  $ARGS .= 'm';
}
if ( $opt_p ) {
  $ARGS .= 'p';
}


  
foreach my $file (@FILES) {

  print "\nchecking file $file\n" if ($opt_v);

  open FILE , '<' , $file or die $fileNotFound;
  my @files = <FILE>;
  close FILE;

  foreach (@files) {
    if ( /^((abstract\s+)?class(\s+\w+)*)/ ) {
      $class = $1;
      last;
    }
    
  }
  
  if ( $ARGS =~ 'l' ) {
    if ( $ARGS =~ 'm' ) {

      list_methods(@files);
    }
    if ( $ARGS =~ 'p' ) {
      list_properties(@files);
    }
  }
  if ( $ARGS =~ 'c' ) {
    if ( $ARGS =~ 'm' ) {
      check_method_parameters_declaration(@files);
      show_errors($err_cnt);
      $err_cnt = 0;
    }

    if ( $ARGS =~ 'p' ) {
      check_properties_declaration(@files);
      show_errors($err_cnt);
    }
  }
}


sub show_errors {
  if ($err_cnt) {
    print "  found $err_cnt ";
    print my $t = ($err_cnt == 1)?'error':'errors';
    print "\n";
  }
  else {
    print "\\o/\n";
  }
}


sub find_files {

  my $folder = shift;

  my @FOLDERS = ($folder);
  my @ITEMS;
  my @FILES;
  foreach my $folder ( @FOLDERS ) {
    
    $folder .= "/";
    
    opendir ( DRIVE , $folder ) || print  "\n\n      ! $folder : Access denied " ;
    @ITEMS= grep ( !/^\.\.?$/ , readdir DRIVE) ;
    closedir(DRIVE);

    foreach (@ITEMS) {
      $_ = $folder . $_;
      if (-d $_) {                       
        push ( @FOLDERS , $_);
      }
      elsif (( -f ) and ( /\.php/ )) {
#         print "$_\n";
        push ( @FILES , $_);
      }
    }
  }
  return @FILES;
}
