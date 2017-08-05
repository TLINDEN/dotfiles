#!/usr/bin/perl -w
#
# parse REZKONV text, format description:
# https://github.com/thinkle/gourmet/issues/98#issuecomment-11657320

use strict;
use Data::Dumper;
use FileHandle;

my ($IN, $OUT) = @ARGV;
my $catmode;

# we support files or pipes, depending on what's missing
if (!$OUT) {
  *OUT = *STDOUT;
}
elsif ($OUT eq '.N') {
  $catmode = 1;
}
else {
  open OUT, ">$OUT" or die "Could not open $OUT: $!\n";
}

if (! $IN) {
  *IN = *STDIN;
}
else {
  if ($IN eq '-h') {
    print STDERR qq(Usage $0 [<rezkonv in-file> [<orgmode out-file>]]\n
- if no in-file given, read from stdin
- if no out-file given, write to stdout
- if \$DEBUGRK=1, dump parser result
);
    exit;
  }
  open IN, "<$IN" or die "Could not open $IN: $!\n";
}

select OUT;
my $inrec = 0;
my $rec;
my @list;

while (<IN>) {
  if (/^\-?=====.*rezkonv/i) {
    $inrec = 1;
    $rec = '';
  }
  elsif (/^=====[=\r\n]*$/) {
    if ($inrec) {
      push @list, $rec;
      $inrec = 0;
      $rec = '';
    }
  }
  else {
    if ($inrec) {
      $rec .= $_;
    }
  }
}
close IN if($IN);

my %rec;
foreach my $entry (@list) {
  my($title, $ot, @cat, %in, %allin, $amount, $orders,
     $nextsource, $nextingred, $nextform, $source);
  foreach (split /\r?\n/, $entry) {
    if (/^\s*$/) {
      # empty line
      next if(! $title && !$orders); # ignore
      if ($nextform) {
        # keep for formulation, capture
        $orders .= "$_\n";
      }
    }
    elsif (/(title|titel):\s*(.*)\s*$/i) {
      $title = $2;
    }
    elsif (/(yield|menge):\s*(.*)\s*$/i) {
      $amount = $2;
    }
    elsif (/(categories|kategorien):\s*(.*)\s*$/i) {
	  my $c = $2;
	  if ($c) {
		@cat = split /\s*,\s*/, $2;
	  }
    }
    elsif (/(zutaten|ingredients):/i) {
      # everything following until formulation
      $nextingred = 'main';
    }
    elsif (/(zubereitung|formulation):/i) {
      # everything following until empty line
      $nextform   = 1;
      $nextingred = 0;
      $nextsource = 0;
    }
    elsif (/====.*quelle/i) {
      # next line is source
      $nextsource = 1;
      $nextingred = 0;
    }
    elsif (/=====*\s*([^=]*)\s*=====/) {
      if ($nextingred) {
        # sub-ingred
        $nextingred = $1;
      }
      else {
        # ignore those inside recepts
        next;
      }
    } else {
      # regular text unless special
      if ($nextsource) {
        # capture source
        $source = $_;
        $source =~ s/\s*//;
        $nextsource = 0; #reset
      }
      elsif ($nextingred) {
        # capture ingredient list
        if (/^(.{7})(.{11})(.*)/) {
          # parse by fixed field sizes, not sure if ok
          my $count = $1;
          my $unit  = $2;
          my $what  = $3;
          if ($count =~ /\d/) {
            $count =~ s/^\s*//;
            $unit  =~ s/^\s*//;
            $what  =~ s/^\s*//;
            push @{$in{$nextingred}}, {count => $count, unit => $unit, what => $what};
			$allin{$what} = 1;
          }
        }
      }
      else {
        # regular anything
        if (/^:[a-zA-Z]/) {
          # ignore arbitrary tags
          next;
        }
        elsif (/^:\s*O-(title|titel)\s*:\s*(.*)$/i) {
          # extended title 1st part
          $ot = $2;
        }
        elsif ($ot) {
          # extended title last part & end of file
          $title = "$ot $_";
        }
        else {
          # capture formulation
          $orders .= "$_\n";
        }
      }
    }
  }
  my $one = 0;
  if (scalar keys %in == 1) {
    my $k = (keys %in)[0];
    $in{main} = delete $in{$k};
    $one = 1;
  }
  if (! @cat) {
	@cat = qw(unsorted);
  }
  $rec{$title} = {
                  orders => $orders,
                  tags   => \@cat,
                  amount => $amount,
                  ingred => \%in,
				  allingred => [sort keys %allin],
                  source => $source,
                  one    => $one
                 };
}


no strict 'refs';
sub ingr {
  my ($list) = @_;
  foreach my $entry (@{$list}) {
    printf "|     %7s | %10s | %-35s |\n", $entry->{count}, $entry->{unit}, $entry->{what};
  }
}

sub prrec {
  my ($title) = @_;
  print  "* $title\n";
  print  "  :PROPERTIES:\n";
  print  "  :Quelle: $rec{$title}->{source}\n" if ($rec{$title}->{source});

  if (! $catmode) {
	foreach my $tag (@{$rec{$title}->{tags}}) {
	  print "  :Kategorie+: $tag\n";
	}
  }
  print "  :END:\n";
  print "** Zutaten\n";
  if ($rec{$title}->{one}) {
	ingr($rec{$title}->{ingred}->{main});
  }
  else {
	foreach my $entry (sort keys %{$rec{$title}->{ingred}}) {
	  ingr($rec{$title}->{ingred}->{$entry});
	}
  }
  print "** Zubereitung\n";
  print join "\n", split /\n/, $rec{$title}->{orders};
  print "\n";
}

my %catfd;

if ($ENV{DEBUGRK}) {
  print Dumper(\%rec);
}
else {
  if (! $catmode) {
	print "#-*- mode: org -*-\n#+STARTUP: hideall\n\n";
  }
  foreach my $title (sort keys %rec) {
    next if(! $rec{$title}->{orders}); # invalid
	if ($catmode) {
	  foreach my $tag (@{$rec{$title}->{tags}}) {
		if (! exists $catfd{$tag}) {
		  $catfd{$tag} = FileHandle->new;
		  $catfd{$tag}->open(">${tag}.org");
		  $catfd{$tag}->print( "#-*- mode: org -*-\n#+STARTUP: hideall\n\n");
		}
		select $catfd{$tag};
		prrec($title);
	  }
	}
	else {
	  prrec($title);
	}
  }
}


if ($catmode) {
  foreach my $tag (keys %catfd) {
	$catfd{$tag}->close();
  }
}
