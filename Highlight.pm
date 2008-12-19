package Term::Highlight;

require Exporter;

use strict;

our @ISA = qw( Exporter );

our @EXPORT = qw( LoadArgs LoadPatterns ClearPatterns Process );

our $VERSION = "1.2";


sub new
{
    my $class = shift;
    my $self = { @_ };
    bless $self, ref $class || $class;
}


sub ByPositions
{
    #comparison order:
    #1. start position,
    #2. start/end of the pattern flag (-1, 0 or 1)
    #3. length of the found pattern
    return $$a[ 0 ] <=> $$b[ 0 ] if $$a[ 0 ] != $$b[ 0 ];
    return $$a[ 2 ] <=> $$b[ 2 ] if $$a[ 2 ] != $$b[ 2 ];
    return - ( $$a[ 1 ] <=> $$b[ 1 ] ) if $$a[ 2 ] == 1;
    return ( $$a[ 1 ] <=> $$b[ 1 ] ) if $$a[ 2 ] == 0 || $$a[ 2 ] == -1;
}


sub PrintPosition
{
    my ( $position, $header ) = @_;
    #start position, length, start(1) or end(0) of pattern,
    #pattern number, pattern, fg color id,
    #bold, bg color id
    print "$header: $$position[ 0 ], $$position[ 1 ], $$position[ 2 ],
                    $$position[ 3 ], ${ $$position[ 4 ] }->[ 0 ], ${ $$position[ 4 ] }->[ 1 ],
                    ${ $$position[ 4 ] }->[ 2 ], ${ $$position[ 4 ] }->[ 3 ]\n";
}


sub LoadArgs
{
    my ( $self, $args ) = @_;
    my ( $ignorecase, $fgcolor, $bold, $bgcolor );
    my $lastPatternOmitted = 0;
    while ( my $arg = shift @$args )
    {
        SWITCH_ARGS:
        {
            if ( $arg =~ /^-(.*)/ )
            {
                SWITCH_OPTS:
                {
                    if ( $1 eq "i" )    { $ignorecase = "i"; last SWITCH_OPTS }
                    if ( $1 eq "ni" )   { $ignorecase = ""; last SWITCH_OPTS }
                    if ( $1 eq "rfg" )  { $fgcolor = undef; last SWITCH_OPTS }
                    if ( $1 eq "rb" )   { $bold = undef; last SWITCH_OPTS }
                    if ( $1 eq "rbg" )  { $bgcolor = undef; last SWITCH_OPTS }
                    if ( $1 eq "r" )    { $bold = undef; $bgcolor = undef; last SWITCH_OPTS }
                    if ( $1 eq "ra" )   { $fgcolor = undef; $bold = undef; $bgcolor = undef;
                                          last SWITCH_OPTS }
                    if ( $1 eq "b" )    { $bold = 1; last SWITCH_OPTS }
                    if ( ( my $orig = $1 ) =~ /\d{1,3}(?=\.1)/ )
                                        { $bgcolor = substr $orig, $-[ 0 ], $+[ 0 ] - $-[ 0 ];
                                          last SWITCH_OPTS }
                    if ( ( my $orig = $1 ) =~ /\d{1,3}(?=\.0)?/ )
                                        { $fgcolor = substr $orig, $-[ 0 ], $+[ 0 ] - $-[ 0 ];
                                          last SWITCH_OPTS }
                    print __PACKAGE__, " : Warning: unknown option '-$1'\n";
                }
                $lastPatternOmitted = 1;
                last SWITCH_ARGS;
            }
            $bold ||= 0;    #make libvte happy (though xterm does not need it to be set explicitly)
            #populate patterns data
            if ( $ignorecase )
            {
                push @{ $self->{ Patterns } }, [ qr/$arg/i, $fgcolor, $bold, $bgcolor ];
            }
            else
            {
                push @{ $self->{ Patterns } }, [ qr/$arg/, $fgcolor, $bold, $bgcolor ];
            }
            $lastPatternOmitted = 0;
        }
    }
    #push undefined pattern for last options not followed by any pattern
    #which will apply for the whole string
    push @{ $self->{ Patterns } }, [ undef, $fgcolor, $bold ] if $lastPatternOmitted;
}


sub LoadPatterns
{
    my ( $self, $patterns ) = @_;
    push @{ $self->{ Patterns } }, @$patterns;
}


sub ClearPatterns
{
    my $self = shift;
    @{ $self->{ Patterns } } = ();
}


sub FindPositionsOfTags
{
    my ( $positions, $patterns, $string_ref ) = @_;
    my $result = 0;
    for ( my $i = 0; $i < @$patterns; ++$i )
    {
        unless ( defined $$patterns[ $i ][ 0 ] )
        {
            my $length = length $$string_ref;
            push @$positions, ( [ 0, $length, 1, $i, \$$patterns[ $i ] ],
                                [ $length, $length, 0, $i, \$$patterns[ $i ] ] );
            ++$result;
        }
        else
        {
            while ( $$string_ref =~ /$$patterns[ $i ][ 0 ]/g )
            {
                push @$positions, ( [ $-[ 0 ], $+[ 0 ] - $-[ 0 ], 1, $i, \$$patterns[ $i ] ],
                                    [ $+[ 0 ], $+[ 0 ] - $-[ 0 ], 0, $i, \$$patterns[ $i ] ] );
                ++$result;
            }
        }
    }
    $result;
}


sub RearrangePositionsOfTags
{
    my ( $positions, $patterns ) = @_;
    #@counts is a stack of not-ended pattern starts
    my @counts;
    for my $position( sort ByPositions @$positions )
    {
        #PrintPosition( $position, "Pos1" );
        if ( $$position[ 2 ] )      #current start position
        {
            push @counts, [ $$position[ 3 ], $$position[ 1 ] ];
        }
        else                        #current end position
        {
            #remove first matching pattern count number from @counts
            my $found_count;
            for ( my $i = 0; $i < @counts; ++$i )
            {
                if ( $counts[ $i ][ 0 ] == $$position[ 3 ] )
                {
                    $found_count = $i;
                    last;
                }
            }
            if ( defined $found_count )
            {
                splice( @counts, $found_count, 1 );
                #end of found pattern are changed by start of a pattern
                #which corresponds to the last element in the @counts
                if ( @counts )
                {
                    $$position[ 1 ] = $counts[ $#counts ][ 1 ];
                    $$position[ 2 ] = -1;   #not 1 for correct work of ByPositions()
                    $$position[ 3 ] = $counts[ $#counts ][ 0 ];
                    $$position[ 4 ] = \$$patterns[ $counts[ $#counts ][ 0 ] ];
                }
            }
        }
        #PrintPosition( $position, "Pos2" );
    }
}


sub InsertTags
{
    my ( $positions, $string_ref, $tagtype ) = @_;
    my $offset = 0;
    my $colortag = "";
    for my $position( sort ByPositions @$positions )
    {
        #PrintPosition( $position, "Pos3" );
        if ( $$position[ 2 ] )      #position of the starting tag
        {
            SWITCH_TAGTYPE:
            {
                if ( $tagtype eq "term" )
                {
                    use integer;
                    #color id in [0..15]
                    if ( ${ $$position[ 4 ] }->[ 1 ] < 16 && ${ $$position[ 4 ] }->[ 3 ] < 16 )
                    {
                        my $fgcolor = ';3' . ${ $$position[ 4 ] }->[ 1 ] % 8 if defined
                                        ${ $$position[ 4 ] }->[ 1 ];
                        my $bgcolor = ${ $$position[ 4 ] }->[ 3 ] % 8 if defined
                                        ${ $$position[ 4 ] }->[ 3 ];
                        my $bold = ${ $$position[ 4 ] }->[ 1 ] / 8 if defined
                                        ${ $$position[ 4 ] }->[ 1 ];
                        #bold is ever 1 if bgcolor is set (xterm restriction)
                        $bold = 1 if $bgcolor;
                        $bold ||= ${ $$position[ 4 ] }->[ 2 ];
                        $bgcolor = '4' . $bgcolor . ';' if defined $bgcolor;
                        $colortag = qq/\033[$bgcolor$bold${fgcolor}m/;
                    }
                    #color id in [16..255]
                    else
                    {
                        $colortag = qq/\033[${ $$position[ 4 ] }->[ 2 ];38;5;${ $$position[ 4 ] }->[ 1 ]m/
                                        if ${ $$position[ 4 ] }->[ 1 ];
                        $colortag .= qq/\033[48;5;${ $$position[ 4 ] }->[ 3 ]m/
                                        if ${ $$position[ 4 ] }->[ 3 ];
                    }
                    last SWITCH_TAGTYPE;
                }
                if ( $tagtype eq "debug" || $tagtype eq "debug-term" )
                {
                    $colortag = "{_$$position[ 3 ]_"; last SWITCH_TAGTYPE;
                }
            }
        }
        else                        #position of the closing tag
        {
            SWITCH_TAGTYPE:
            {
                if ( $tagtype eq "term" ) { $colortag = qq/\033[0m/; last SWITCH_TAGTYPE; }
                if ( $tagtype eq "debug" || $tagtype eq "debug-term" )
                {
                    $colortag = "_$$position[ 3 ]_}"; last SWITCH_TAGTYPE;
                }
            }
        }
        substr( $$string_ref, $$position[ 0 ] + $offset, 0 ) = $colortag;
        $offset += length( $colortag );
    }
}


sub Process
{
    #string to process
    my ( $self, $String_ref ) = @_;
    #@Positions contains the start and end positions of all found patterns in the current string
    #and other data relative to the patterns (length of found pattern, start/end_of_pattern flag,
    #pattern count number and a reference to pattern data)
    my @Positions;

    #populate @Positions
    my $found_matches = FindPositionsOfTags( \@Positions, \@{ $self->{ Patterns } }, $String_ref )
        or return 0;

    #do not change original string and return found positions if an array is expected
    return @Positions if wantarray;

    #replace all but the last ending tags from @Positions by one-before-the-last starting tag
    #(crucial for terminal color escape sequences algorithm)
    RearrangePositionsOfTags( \@Positions, \@{ $self->{ Patterns } } );
    
    #insert tags into current line
    InsertTags( \@Positions, $String_ref, $$self{ tagtype } );

    $found_matches;
}


=head1 NAME

Term::Highlight - perl module to highlight regexp patterns on terminals

=head1 SYNOPSIS

=over

=item use Term::Highlight;

=item $obj = Term::Highlight->new( tagtype => $TAGTYPE );

=item $obj->LoadArgs( \@args );

=item $obj->LoadPatterns( \@ptns );

=item $obj->ClearPatterns( );

=item $obj->Process( \$string );

=back

Currently C<term> and C<term-debug> tagtypes are supported.
If tagtype is C<term> then boundaries of found patterns will be enclosed in
terminal color escape sequence tags, if tagtype is C<term-debug> then they
will be marked by symbolic sequences.

=head1 DESCRIPTION

Term::Highlight is perl module aimed to support highlighting of patterns
on color terminals. It supports 256 color terminals and older
8 color terminals.

=head1 EXPORTS

=over

=item B<LoadPatterns>

expects reference to array of references to arrays of structure
[ $pattern, $fg, $bold, $bg ]. Load patterns to be processed.

=item B<ClearPatterns>

clear loaded patterns.

=item B<LoadArgs>

expects array of references to strings. Loads patterns to be processed.
This is just a convenient version of C<LoadPatterns>.
Example of array to be loaded:
[ "-46", "-25.1", "-i", "\bw.*?\b", "-100" ].

=item B<Process>

expects reference to string. Make substitution of color tags inside the
string. Returns count of found matches.

=back

=head1 SEE ALSO

hl(1)

=head1 AUTHOR

A. Radkov, E<lt>alexey.radkov@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by A. Radkov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
