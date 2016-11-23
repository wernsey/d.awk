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

!in_comment && /\/\*\*/ {
	in_comment = 1;
	sub(/\/\*\*/,"");
}
in_comment && /\*\// { in_comment = 0; }
in_comment && /^[[:space:]]*\*/ {	
	sub(/^[[:space:]]*\*/,"");
}
in_comment { print; }