#!/usr/bin/perl -w
# player_matcher.pl --- 
# Author: Yanyi Wan <stephen@ubuntu>
# Created: 19 May 2013
# Version: 0.01

use warnings;
use strict;
use 5.014;
use List::Util qw(sum first);
use Memoize qw(memoize);


INIT {
    my $min_from_t;
    sub get_min_from_t {
        return $min_from_t;
    }        
    sub seek_target {
        my ($t, $first, @rest) = @_;
        return if $t <= 0;

        if ( $t == $first) {
            $min_from_t = 0;
            return $first;
        }

        $min_from_t = (!defined $min_from_t or $min_from_t > $t)?$t:$min_from_t;        
        return unless @rest;

        my @sub_result = seek_target ( $t- $first, @rest);
    
        if ( @sub_result) {
            return ($first, @sub_result);
        } else {
            return seek_target ($t, @rest);
        }    
    }

    sub normalize_seek_paras {
        my ($t, @seq) = @_;                
        join ',', $t, sort {$b <=> $a} @seq;        
    }
    
    memoize ('seek_target', NORMALIZER=> 'normalize_seek_paras');
}


die "Please input the filename that stores the player ranks.\n" unless @ARGV == 1 and -e (my $filename = $ARGV[0]);
open my $fh, $filename or die "Cannot open the input file $filename.";

my %precords = ();

for ( <$fh>) {
    my @pieces = ($_ =~ m<(\w+)\s+(\d+)> );
    %precords = (%precords, @pieces) if @pieces == 2;    
}

my @players = keys %precords;
my $target = sum( values %precords)/2;

for ( keys %precords) {
    say $_, "  ", $precords{$_};    
}

if (my @seq = seek_target($target, values %precords) ) {
    translate_scores(@seq);
} else {
    my $new_target = $target - get_min_from_t;    
    translate_scores(seek_target($new_target, values %precords));    
}

sub translate_scores {
    my @scores = @_;
    my @a_side = map { my $score = $_; first {$precords{$_} == $score } @players  } @scores;
    my @b_side = grep {my $player = $_; !defined(first {$player eq $_} @a_side )} @players;

    say "Group A: @a_side  | total=>  ", sum(map {$precords{$_}} @a_side);
    say "Group B: @b_side  | total=>  ", sum(map {$precords{$_}} @b_side);
}
















__END__

=head1 NAME

player_matcher.pl - Describe the usage of script briefly

=head1 SYNOPSIS

player_matcher.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for player_matcher.pl, 

=head1 AUTHOR

Yanyi Wan, E<lt>stephen@ubuntuE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Yanyi Wan

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
