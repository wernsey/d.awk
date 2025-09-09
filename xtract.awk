#! /usr/bin/awk -f
#
# Extracts the /**-denoted comments from a source file.
# https://github.com/wernsey/d.awk
#
# (c) 2016 Werner Stoop
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved. This file is offered as-is,
# without any warranty.

!Multi && /\/\*\*/ {
    sub(/^.*\/\*/,"");
    Multi = 1;
}
Multi {
    if(match($0, /\*\//)) {
        gsub(/\*\/.*$/,"");
        Multi = 0;
    }
    gsub(/\r/, "", $0);
    
    gsub(/^[[:space:]]+/,"",$0);
    if(substr($0,1,1)=="*") {
        print substr($0,2);
    } else if(!Multi) {
        print;
    }
}


# For `///` single-line comments:
Single && $0 !~ /\/\/\// {
    Single=0;
    print "\n";
}
Single && /\/\/\// {
    sub(/^.*\/\/\//,"");
    print $0;
}
!Single && /\/\/\// {
    sub(/^.*\/\/\//,"");
    print $0;
    Single=1;
}