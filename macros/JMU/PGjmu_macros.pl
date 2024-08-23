=head1 PGjmu_macros.pl DESCRIPTION

 #############################
 #  This macro file contains routines that were deemed useful
 #  in preparing WW problems for the JMU collection of problems.
 #
 #  Copyright 2010 D. Brian Walton, James Madison University
 #  Version 1.0.0
 #############################
 
=cut

=head3 $monStr = GenMonTeX( $p, $q, $k, $posFlag );
=pod
    Create the equivalent to (p/q)x^k, but using only positive powers.
    The $posFlag=1 option is not required unless you want to include a leading +.
=cut

sub GenMonTeX{
    # Determine the input parameters.
    my $narg = @_;
    my $p = $_[0];
    my $q = $_[1];
    my $k = $_[2];

    my ($sign, $pStr, $qStr, $powStr, $monStr);
    my ($posFlag, $pm, $km);

    if ($narg>3) {
        $posFlag = $_[3];
    } else {
        $posFlag = 0;
    }

    ($p, $q) = FractionReduce($p, $q);
    $pm = abs($p);
    if ($pm == 0) {
        if ($posFlag == 1) {
            $monStr = "";
        } else {
            $monStr = "0";
        }
    } else {
         if ($p < 0) {
            $sign = "-";
        } elsif ($posFlag == 1) {
            $sign = "+";
        } else {
            $sign = "";
        }

        $km = abs($k);
        if ($k == 0) {
            $powStr = "";
        } elsif ($km == 1) {
            $powStr = "x";
        } else {
            $powStr = "x^{$km}";
        }
        if ($k >= 0) {
            if ($pm == 1 && $k > 0) {
                $pStr = "";
            } else {
                $pStr = "$pm";
            }
            if ($q == 1) {
                $monStr = $sign . "$pStr $powStr";
            } else {
                $monStr = $sign . "\\frac{$pStr}{$q} $powStr";
            }
        } else {
            if ($q == 1) {
                $qStr = "";
            } else {
                $qStr = "$q";
            }
            $monStr = $sign . "\\frac{$pm}{$qStr $powStr}";
        }
    }

    return $monStr;
}



=head3 $monStr = GenMonString( $p, $q, $k, $posFlag );
=pod
    Create the equivalent to (p/q)x^k, but using only positive powers.
    The $posFlag=1 option is not required unless you want to include a leading +.
=cut

sub GenMonString{
    # Determine the input parameters.
    my $narg = @_;
    my $p = $_[0];
    my $q = $_[1];
    my $k = $_[2];

    my ($sign, $pStr, $qStr, $powStr, $monStr);
    my ($posFlag, $pm, $km);

    if ($narg>3) {
        $posFlag = $_[3];
    } else {
        $posFlag = 0;
    }

    ($p, $q) = FractionReduce($p, $q);
    $pm = abs($p);
    if ($pm == 0) {
        if ($posFlag == 1) {
            $monStr = "";
        } else {
            $monStr = "0";
        }
    } else {
         if ($p < 0) {
            $sign = "-";
        } elsif ($posFlag == 1) {
            $sign = "+";
        } else {
            $sign = "";
        }

        $km = abs($k);
        if ($k == 0) {
            $powStr = "";
        } elsif ($km == 1) {
            $powStr = "x";
        } else {
            $powStr = "x^{$km}";
        }
        if ($k >= 0) {
            if ($pm == 1 && $k > 0) {
                $pStr = "";
            } else {
                $pStr = "$pm";
            }
            if ($q == 1) {
#                $monStr = $sign . "$pStr $powStr (A: $po $qo)";
                $monStr = $sign . "$pStr $powStr";
            } else {
#                $monStr = $sign . "[($pStr $powStr)/$q (B: $po $qo)]";
                $monStr = $sign . "[($pStr/$q) $powStr]";
            }
        } else {
            if ($q == 1) {
                $qStr = "";
            } else {
                $qStr = "$q";
            }
#            $monStr = $sign . "[$pm/($qStr $powStr) (C: $po $qo)]";
            $monStr = $sign . "[$pm/($qStr $powStr)]";
        }
    }

    return $monStr;
}



=head3 $genpoly = GenPolyTeX( $nmax, ~~@pc, ~~@qc);
=pod
    This function allows a generalization of polynomials, where
    coefficients are rational numbers and powers can include
    negative integers.
=cut

sub GenPolyTeX{
    # Determine the input parameters.
    my $nP = @_;
    my $nmax = $_[0];

     #  Find how many terms.
    my @pc = @{$_[1]};
    my $n = @pc;

    my @qc;
   if ($nP == 3) {
        @qc = @{$_[2]};
    } else {
        @qc = map(1, 1 .. $n);
    }

    # First term, initialize the string.
    my $genpoly = GenMonTeX($pc[0], $qc[0], $nmax);
    my ($i, $k);
    for ($i = 1; $i<$n; $i++) {
        $k = $nmax - $i;
        $genpoly = $genpoly . GenMonTeX($pc[$i], $qc[$i], $k, 1);
    }
    return $genpoly;
}

=head3 $genpoly = GenPolyTeXRev( $nmax, ~~@pc, ~~@qc);
=pod
    This function allows a generalization of polynomials, where
    coefficients are rational numbers and powers can include
    negative integers. Displays in increasing powers.
=cut
sub GenPolyTeXRev{
    # Determine the input parameters.
    my $nP = @_;
    my $nmax = $_[0];

     #  Find how many terms.
    my @pc = @{$_[1]};
    my $n = @pc;

    my @qc;
   if ($nP == 3) {
        @qc = @{$_[2]};
    } else {
        @qc = map(1, 1 .. $n);
    }

    # First term, initialize the string.
    my $genpoly = GenMonTeX($pc[$n-1], $qc[$n-1], $nmax-$n+1);
    my ($i, $k);
    for ($i = $n-2; $i>=0; $i--) {
        $k = $nmax - $i;
        $genpoly = $genpoly . GenMonTeX($pc[$i], $qc[$i], $k, 1);
    }
    return $genpoly;
}



=head3 $genpoly = GenPolyString( $nmax, ~~@pc, ~~@qc  );
=pod
    This function allows a generalization of polynomials, where
    coefficients are rational numbers and powers can include
    negative integers.
=cut

sub GenPolyString{
    # Determine the input parameters.
    my $nP = @_;
    my $nmax = $_[0];

     #  Find how many terms.
    my @pc = @{$_[1]};
    my $n = @pc;

   my @qc;
   if ($nP == 3) {
        @qc = @{$_[2]};
    } else {
        @qc = map(1, 1 .. $n);
    }

    # First term, initialize the string.
    my $genpoly = GenMonString($pc[0], $qc[0], $nmax);
    my ($i, $k);
    for ($i = 1; $i<$n; $i++) {
        $k = $nmax - $i;
        $genpoly = $genpoly . GenMonString($pc[$i], $qc[$i], $k, 1) ;
    }
    return $genpoly;
}




=head3 $genpoly = GenPolyStringRev( $nmax, ~~@pc, ~~@qc  );
=pod
    This function allows a generalization of polynomials, where
    coefficients are rational numbers and powers can include
    negative integers. Display in increasing powers.
=cut

sub GenPolyStringRev{
    # Determine the input parameters.
    my $nP = @_;
    my $nmax = $_[0];

     #  Find how many terms.
    my @pc = @{$_[1]};
    my $n = @pc;

   my @qc;
   if ($nP == 3) {
        @qc = @{$_[2]};
    } else {
        @qc = map(1, 1 .. $n);
    }

    # First term, initialize the string.
    my $genpoly = GenMonString($pc[$n-1], $qc[$n-1], $nmax-$n+1);
    my ($i, $k);
    for ($i = $n-2; $i>=0; $i--) {
        $k = $nmax - $i;
        $genpoly = $genpoly . GenMonString($pc[$i], $qc[$i], $k, 1) ;
    }
    return $genpoly;
}


=head3 ($numer, $denom) = FractionReduce( $oldN, $oldD );
=pod
    This function reduces a rational number by any common factors and
    ensures that the denominator is a positive number.
=cut

sub FractionReduce{
    my $narg = @_;
    my ($n, $d, $k);

    if ($narg == 1) {
        $n = $_[0];
        $d = 1;
    } elsif ($narg == 2) {
        $n = $_[0];
        $d = $_[1];
    } else {
        $n = 0;
        $d = 1;
    }

    if ($d < 0) {
        $n = -$n;
        $d = -$d;
    }
    for ($k=2; $k <=$d; $k++) {
        while ($n % $k == 0 && $d % $k == 0) {
            $n = $n/$k;
            $d = $d/$k;
        } 
    }
    return ($n, $d);
}

=head3 $str = FractionTeX( $n, $d );
=pod
    This function creates a TeX-formatted string to represent a rational number.
    If $d == 1, the fraction is simplified to an integer.
=cut

sub FractionTeX{
    my $n = $_[0];
    my $d = $_[1];

    my $str = GenMonTeX($n, $d, 0);

    return $str;
}


=head3 $str = FractionString( $n, $d );
=pod
    This function creates a string to represent a rational number.
    If $d == 1, the fraction is simplified to an integer.
=cut

sub FractionString{
    my $n = $_[0];
    my $d = $_[1];

    my $str = GenMonString($n, $d, 0);

    return $str;
}



=head3 @c = PolyMult( ~~@a, ~~@b );
=pod
    This function multiplies two polynomials, represented by their arrays of simple coefficients,
    by calculating the convolution of the two arrays.
=cut

sub convolute{
    my $narg = @_;
    my (@a, @b, @c);
    my ($k, $n);
    if ($narg == 2) {
        @a = @{$_[0]};
        $k = @a;
        @b = @{$_[1]};
        $n = @b;
        @c = map( 0, 0..($n+$k-2) );

        my ($i, $j);
        for ($i=0; $i<$k; $i++) {
            for ($j=0; $j<$n; $j++) {
               $c[$i+$j] += $a[$i]*$b[$j];
            }
        }
        return @c;
    } else {
        return ();
    }
}

sub PolyMult{
    return convolute(@_);
}


=head3 @c = PolyAdd( ~~@a, ~~@b );
=pod
    This function multiplies two polynomials, represented by their arrays of integer coefficients,
    by calculating the convolution of the two arrays.  Assumes all coefficients.
    DO NOT USE for general polynomials.
=cut
sub PolyAdd{
    my $narg = @_;
    my (@a, @b, @c);
    my ($k, $m, $n);
    if ($narg == 2) {
        @a = @{$_[0]};
        $k = @a;
        @b = @{$_[1]};
        $m = @b;

        $n = max($k,$m);
        @c = map( 0, 1..$n );

        my $i;
        for ($i=0; $i<$k; $i++) {
            $c[$n-($k-$i)] += $a[$i];
        }
        for ($i=0; $i<$m; $i++) {
            $c[$n-($m-$i)] += $b[$i];
        }

        return @c;
    } else {
        return ();
    }
}
