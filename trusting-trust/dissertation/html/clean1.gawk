#!/usr/bin/gawk -f

/=$/ {printf "%s", $0}
/[^=]$/ {print}
/^$/ {print}

