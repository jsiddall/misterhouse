###########################################################################
#
# This file is auto-generated by the Perl DateTime Suite time locale
# generator (0.03).  This code generator comes with the
# DateTime::Locale distribution in the tools/ directory, and is called
# generate_from_cldr.
#
# This file as generated from the CLDR XML locale data.  See the
# LICENSE.cldr file included in this distribution for license details.
#
# This file was generated from the source file ko_KR.xml.
# The source file version number was 1.45, generated on
# 2006/07/11 19:26:44.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::ko_KR;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::ko;

@DateTime::Locale::ko_KR::ISA = qw(DateTime::Locale::ko);



sub medium_time_format             { "\%p\ \%\{hour_12\}\:\%M\:\%S" }
sub short_time_format              { "\%p\ \%\{hour_12\}\:\%M" }



1;

