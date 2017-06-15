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
    Multi = 1;
    sub(/^.*\/\*\*/,"");
}
Multi && /\*\// {
    sub(/[[:space:]]*\*\/.*/,"");
    if($0) {
    sub(/^[[:space:]]*\*/,"");
        print $0 "\n";
    } else print "";
    Multi = 0;
}
Multi && /^[[:space:]]*\*/ {
    sub(/^[[:space:]]*\*/,"");
}
Multi { print; }

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