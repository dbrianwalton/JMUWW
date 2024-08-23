=head1 PGjmu_poly.pl DESCRIPTION

 #############################
 #  This macro file contains routines relating to polynomials
 #  that were deemed useful in preparing WW problems for the 
 #  JMU collection of problems.
 #
 #  Originally part of PGjmu_macros.pl, but somewhat generalized since.
 #
 #  Copyright 2012 D. Brian Walton, James Madison University
 #  Version 1.0.0
 #############################
 
=cut

=head3 $monStr = GenMonEncode( [$|~~@]p, [$|~~@]k, "mode"=>["TeX"|"String"], "leadFlag"=>0, "inFrac"=>1, "x"=>"x");
=pod
    Create the equivalent to p x^k.
    p is a scalar or reference to an array: p or  (p[0]/p[1])
    k is a scalar or reference to an array: k or  (k[0]/k[1])
    "leadFlag"=>1 to force leading "+"
    "inFrac"=>1 puts x^k in fraction with positive power
    "x"=>"u" uses u as the variable in place of x
    "antiD"=>1 generates the antiderivative of generalized polynomial
=cut

sub GenMonEncode{
    # Determine the input parameters.
    my $p = shift;    # Reference to coefficient
    my $k = shift;    # Reference to power
    my %params = @_;  # Remaining parameters as hash

    # Set up the defaults on the parameters.
    my ($posFlag, $inFracFlag, $texMode, $x, $antiDFlag) = (0, 0, 1, "x", 0);

    if (exists $params{"mode"}) {
        $texMode = ($params{"mode"} eq "TeX");
    }
    if (exists $params{"leadFlag"}) {
        $posFlag = $params{"leadFlag"};
    }
    if (exists $params{"inFrac"}) {
        $inFracFlag = $params{"inFrac"};
    }
    if (exists $params{"antiD"}) {
        $antiDFlag = $params{"antiD"};
    }
    if (exists $params{"x"}) {
        $x = $params{"x"};
    }

    my ($sign, $pStr, $qStr, $powStr, $monStr);
    my ($pn, $pd, $kn, $kd, $pm, $km);
    my $log = ($texMode==1) ? "\ln" : "ln";

    # See if the coefficient is a scalar or array.
    unless (ref($p)) {
        ($pn, $pd) = ($p, 1);
    } elsif (ref($p) eq "ARRAY") {
        ($pn, $pd) = (@$p >= 2)
            # Use FractionReduce to eliminate common factors.
            ? FractionReduce($p->[0], $p->[1])
            : ($p->[0], 1);
    } else {  # Allow for other references that produce values
        ($pn,$pd) = ($p,1);
    }

    # See if the power is a scalar or array.
    unless (ref($k)) {
        ($kn,$kd) = ($k, 1);
    } elsif (ref($k) eq "ARRAY") {
	($kn,$kd) = (@$k >= 2)
            # Use FractionReduce to eliminate common factors.
	    ? FractionReduce($k->[0], $k->[1])
	    : ($k->[0], 1);
    } else {
        ($kn,$kd) = ($k,1);
    }
    
    if ($antiDFlag == 1) {
        ($kn, $kd) = FractionReduce($kn+$kd, $kd);
        unless ($kn == 0) {
            ($pn, $pd) = FractionReduce($pn*$kd, $pd*$kn);
        }
    }

    # We want $km to be negative if always multiply by x^k
    $km = ($kn < 0 && $inFracFlag == 1) ? abs($kn) : $kn;

    $pm = abs($pn);
    if ($pm == 0) {
        $monStr = ($posFlag == 1) ? "" : "0";
    } else {
        $sign = ($pn<0) ? "-" : (($posFlag==1) ? "+" : "");
        $powStr = ($kn==0) 
	    ?  ($antiDFlag==1 
	      ? "$log(|$x|)" 
	      : "") 
	    : ($kd==1 
		  ? ($km==1 
		     ? $x 
		     : $x . ($texMode==1 ? "^{$km}" : "^$km"))
		  : $x . ($texMode==1 ? "^{$km/$kd}" : "^($km/$kd)")
	    );
        if ($inFracFlag == 1) {
	    if ($kn >= 0) {
                $pStr = ($pm == 1 && $kn > 0) ? "" : "$pm";
                $monStr = $sign . ($pd == 1 
                                   ? "$pStr $powStr" 
                                   : ($texMode==1
				      ? "\\frac{$pStr $powStr}{$pd}"
				      : "($pStr $powStr)/($pd)")
                                  );
	    } else {
                $qStr = ($pd == 1) ? "" : "$pd";
		$monStr = $sign . ($texMode==1
				   ? "\\frac{$pm}{$qStr $powStr}"
				   : "($pm)/($qStr $powStr)");
	    }
	} else {
	    $pStr = ($pd==1 && $pm==1 && $kn!= 0) ? "" : "$pm";
	    $monStr = $sign . ($pd == 1
                               ? "$pStr $powStr"
                               : ($texMode==1
				  ? "\\frac{$pm}{$pd} $powStr"
				  : "($pm/$pd) $powStr")
                              );
	}
    }

    return $monStr;
}



=head3 $monStr = GenMonTeX( [$|~~@]p, [$|~~@]k, "leadFlag"=>0, "inFrac"=>1, "x"=>"x");
=pod
    Create the equivalent to p x^k in TeX format.
    p is a scalar or reference to an array: p or  (p[0]/p[1])
    k is a scalar or reference to an array: k or  (k[0]/k[1])
    "leadFlag"=>1 to force leading "+"
    "inFrac"=>1 puts x^k in fraction with positive power
    "x"=>"u" uses u as the variable in place of x 
=cut
sub GenMonTeX{
    return GenMonEncode(@_, "mode"=>"TeX");
}





=head3 $monStr = GenMonString( [$|~~@]p, [$|~~@]k, "leadFlag"=>0, "inFrac"=>1, "x"=>"x");
=pod
    Create the equivalent to p x^k.
    p is a scalar or reference to an array: p or  (p[0]/p[1])
    k is a scalar or reference to an array: k or  (k[0]/k[1])
    "leadFlag"=>1 to force leading "+"
    "inFrac"=>1 puts x^k in fraction with positive power
    "x"=>"u" uses u as the variable in place of x 
=cut

sub GenMonString{
    return GenMonEncode(@_, "mode"=>"String");
}



=head3 $genpoly = GenPolyEncode( ~~@pc, "k"=>0, "mode"=>["TeX"|"String"], "inFrac"=>1, "ascend"=>0, "x"=>"x" );
=pod
    This function allows a generalization of polynomials.
    Coefficients can be rational numbers specified by array @pc.
     - If elements are 2-arrays, then fractions
     - If elements are 1-arrays or scalars, then simple
    If k is passed, then this multiplies each term by x^k.
     - If k is 2-array, then fractional power.
     - If k is 1-array or scalar, then simple power.
    "inFrac"
       =>1 means write with positive powers in fraction
       =>0 means write coefficient times x to power
    "x"=>"u" changes the variable
=cut

sub GenPolyEncode{
    # Determine the input parameters.
    my $pc = shift;   # Reference to coefficient array.
    my @p = @$pc;
    my %params = @_;

    # Determine the degree of the natural polynomial
    my $n = @p;
    my ($kn, $kd);

    # See if the terms are in ascending powers
    my $goUp = 0;
    if (exists $params{"ascend"}) {
	$goUp = $params{"ascend"};
	delete $params{"ascend"};  # not passed on
    }

    # See if we need to adjust the powers.
    if (exists $params{"k"}) {
        my $k = $params{"k"};
        unless (ref($k)) {
	    ($kn, $kd) = ($k, 1);
        } elsif (ref($k) eq "ARRAY") {
            ($kn, $kd) = (@$k >= 2) ? ($k->[0], $k->[1]) : ($k->[0], 1);
        }
	delete $params{"k"};  # not passed on
    } else {
	($kn, $kd) = (0,1);
    }

    # First term, initialize the string.
    my $genpoly;
    my $hasTerm = 0;
    my ($term, $power);
    for ($i=0; $i<$n; $i++) {
	$term = ($goUp==1) ? $n-$i-1 : $i;
	$power = $n-$term-1;
	$genpoly = ($hasTerm ? $genpoly : "") .
	    GenMonEncode($p[$term], [$power*$kd+$kn,$kd], 
			 "leadFlag"=>$hasTerm, %params);
	$hasTerm = ($genpoly eq "0") ? 0 : 1;
    }
    return $genpoly;
}


=head3 $genpoly = GenPolyTeX(~~@pc, ["k"=>2]);
=pod
    This function allows a generalization of polynomials, where
    coefficients are rational numbers and powers can include
    negative integers. Displays in increasing powers.
=cut
sub GenPolyTeX{
    return GenPolyEncode(@_, "mode"=>"TeX", "ascend"=>0);
}


=head3 $genpoly = GenPolyTeXRev(~~@pc, ["k"=>2]);
=pod
    This function allows a generalization of polynomials, where
    coefficients are rational numbers and powers can include
    negative integers. Displays in increasing powers.
=cut
sub GenPolyTeXRev{
    return GenPolyEncode(@_, "mode"=>"TeX", "ascend"=>1);
}



=head3 $genpoly = GenPolyString(~~@pc, ["k"=>2]);
=pod
    This function allows a generalization of polynomials, where
    coefficients are rational numbers and powers can include
    negative integers.
=cut

sub GenPolyString{
    return GenPolyEncode(@_, "mode"=>"String", "ascend"=>0);
}




=head3 $genpoly = GenPolyStringRev(~~@pc, ["k"=>2]);
=pod
    This function allows a generalization of polynomials, where
    coefficients are rational numbers and powers can include
    negative integers. Display in increasing powers.
=cut

sub GenPolyStringRev{
    return GenPolyEncode(@_, "mode"=>"String", "ascend"=>1);
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
    # We'll only bother with primes less than 100.
    foreach $k (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97) {
        while ($n % $k == 0 && $d % $k == 0) {
            $n = $n/$k;
            $d = $d/$k;
        }
        last if ($k > $d);
    }
    return ($n, $d);
}

=head3 $str = FractionTeX( [$n, $d] );
=pod
    This function creates a TeX-formatted string to represent a rational number.
    If $d == 1, the fraction is simplified to an integer.
=cut

sub FractionTeX{
    my $p = shift;

    my ($a,$b) = FractionReduce($p->[0], $p->[1]);
    my $am = abs($a);
    my $sign = $a>0 ? "" : "-";
    return ($b==1) ? "$a" : $sign . "\\frac{$am}{$b}";
}


=head3 $str = FractionString( [$n, $d] );
=pod
    This function creates a string to represent a rational number.
    If $d == 1, the fraction is simplified to an integer.
=cut

sub FractionString{
    my $p = shift;

    my ($a,$b) = FractionReduce($p->[0], $p->[1]);
    my $am = abs($a);
    my $sign = $a>0 ? "" : "-";
    return ($b==1) ? "$a" : $sign . "($am/$b)";
}



=head3 @c = PolyMult( ~~@a, ~~@b );
=pod
    This function multiplies two polynomials, represented by their arrays 
    of coefficients, by calculating the convolution of the two arrays.
    Coefficients (in arrays) can be either scalars or reference to 2-d array
    of integers to allow for rational numbers.
=cut

sub mult_ratl{
    my $a = shift;
    my $b = shift;
    my $c;

    unless (ref($a) || ref($b)) {
	$c = $a*$b;
    } else {
	unless (ref($a) eq "ARRAY") {
	    $a = [$a, 1];
	}
	unless (ref($b) eq "ARRAY") {
	    $b = [$b, 1];
	}
	$c = [ FractionReduce($a->[0]*$b->[0], $a->[1]*$b->[1])];
    }
    return $c;
}

sub add_ratl{
    my $a = shift;
    my $b = shift;
    my $c;

    unless (ref($a) || ref($b)) {
	$c = $a+$b;
    } else {
	unless (ref($a) eq "ARRAY") {
	    $a = [$a, 1];
	}
	unless (ref($b) eq "ARRAY") {
	    $b = [$b, 1];
	}
	$c = [FractionReduce($a->[0]*$b->[1]+$a->[1]*$b->[0], $a->[1]*$b->[1])];
    }
    return $c;
}

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
               $c[$i+$j] = add_ratl($c[$i+$j], mult_ratl($a[$i],$b[$j]));
            }
        }
        return @c;
    } else {
        return ($narg);
    }
}

sub PolyMult{
    return convolute(@_);
}


=head3 @c = PolyAdd( ~~@a, ~~@b );
=pod
    This function multiplies two polynomials, represented by their arrays 
    coefficients, which can either be scalar or 2-d arrays (rational numbers).
    DO NOT USE for general polynomials since leading power is unclear.
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
            $c[$n-($k-$i)] = add_ratl($c[$n-($k-$i)],$a[$i]);
        }
        for ($i=0; $i<$m; $i++) {
            $c[$n-($m-$i)] = add_ratl($c[$n-($m-$i)],$b[$i]);
        }

        return @c;
    } else {
        return ();
    }
}


=head3 @c = PolyFromRoots( ~~@r );
=pod
    This function defines the polynomial with integer coefficients
    such that the referenced array contains all of the roots.
    Roots can have higher multiplicity.  Rational roots can be
    given as referenced 2-d arrays, e.g. [a,b] is root at a/b.
=cut
sub PolyFromRoots{
    my $rr = shift;
    my @r = @$rr;

    my (@c, @p, @t);
    my $ri;
    @c = (1);
    foreach $ri (@r) {
	unless (ref($ri)) {
	    @p = (1, -$ri);
	} elsif (ref($ri) eq "ARRAY") {
	    @p = @$ri==2 ? ($ri->[1], -$ri->[0]) : (1, -$ri->[0]);
	} else {
	    @p = (1);
	}
	@c = PolyMult(\@c, \@p);
    }

    return @c;
}
