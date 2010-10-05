#
# Simple helper script for overlaying different curvature files
#

# Assume the 40.3 week cGA subject:

set SUBJROOT	"/space/heisenberg/2/users/rudolph/data/newborn/recon-newbornFinal"
set SUBJ	"40.3_4063"
set SUBJPATH  	$SUBJROOT/$SUBJ

set spectralPower	"1 2 3 4 5 6 7"
set principleCurves	"K H K1 K2"

foreach level $spectralPower {
    foreach curve $principleCurves {
	set str_snapshot $SUBJ-WS$level-$curve.jpg
	puts $str_snapshot
    }
}
