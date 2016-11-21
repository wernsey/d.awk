# Like the Un*x `fmt` command, but for markdown.
#
# It does its best to preserve markdown headings,
# lists, pre-formatted code blocks and block quotes.

BEGIN { if(!Width) Width = 80; }

# Preserve headings
/^[[:space:]]*[=\-][=\-][=\-]+/ {
    if(Buf)
        Out = Out Buf "\n" $0 "\n";
    else
        Out = Out $0 "\n";
    Buf = "";
    next;
}

# Preformatted text is sent to the output verbatim
# Ditto for links/abbreviations
/^(    |\t)+/ && match(last,/^[[:space:]]*$/) || /^[[:space:]]*\*?\[.*\]:/ {
    Out = Out $0 "\n";
    next;
}

# GitHub-style ``` code blocks:
/^```/ {
    Out = Out Buf "\n" $0 "\n";
    Buf = "";
    Code = !Code;
    next;
}
Code {
    Out = Out $0 "\n";
    next;
}

$0 !~ /^[[:space:]]*$/ && match(last,/^[[:space:]]*$/) {
    # how much is the current line indented
    match(str, /^[[:space:]]+/);
    Indent = substr(str, 1, RLENGTH);
}

# Blank lines cause blank lines in the output
/^[[:space:]]*$/ {
    # You need to preserve $0 for blank lines in preformatted blocks
    if(Buf)
        Out = Out Buf "\n" $0 "\n";
    else
        Out = Out "\n" $0;
    Buf = "";
    last = $0;
    InList = 0;
    next;
}

# Handle every other input line
{ last = $0; fmt($0); }

# Write output when done
END {
    Out = Out Buf;
    print Out;
}

function fmt(str,          loc,word,n,indent) {

    # Get the current line's indentation level.
    match(str, /^[[:space:]]+/);
    indent = substr(str, 1, RLENGTH);

    # Trim leading whitespace
    str = substr(str, RLENGTH+1);
    gsub(/\r/, "", str); # Windows :(

    # Lines starting with list item characters
    # force a line break in the output
    if(match(str,/^([*+\-]|[[:digit:]]+\.)/)) {
        if(Buf) Out = Out Buf "\n";
        Buf = "";
        # Preserve the indentation in the global Indent
        # if it is a list that is going to be split.
        Indent = indent;
        InList = 1; # remember we're in a list on subsequent calls.
    } else if(match(str,/^>[[:space:]]+/)) {
        Indent = indent substr(str, 1, RLENGTH);
        str = substr(str,RLENGTH+1);
    }

    # Current indentation level = global Indent
    indent = Indent;

    # This implements the simple algorithm from the wikipedia
    # https://en.wikipedia.org/wiki/Line_wrap_and_word_wrap
    # There is a better way. See #Minimum_raggedness on that wiki page.
    # The C code example on https://www.rosettacode.org/wiki/Word_wrap#C
    # may actually be easy to port to Awk (the Awk version on that page
    # implements the greedy algorithm, like I do here).

    loc = match(str, /[[:space:]]+/);
    while(loc) {
        word = substr(str, 1, RSTART-1);
        n = RSTART+RLENGTH;

        # Handle forced line breaks
        if(match(str,/(  |[[:space:]]+\\)$/) == loc) {
            if(length(Buf) + length(str) + 1 >= Width)
                Out = Out Buf "\n" indent str "\n" indent;
            else
                Out = Out Buf " " str "\n" indent;
            Buf = "";
            return;
        }

        # If the buffer + the word exceeds the allowed width
        # then insert a line break. Otherwise, just append the
        # word to the buffer.
        # Also, preserve the indentation.
        if(length(Buf) + length(word) + 1 >= Width) {
            Out = Out Buf "\n";
            if(InList) indent = Indent "  ";
            Buf = indent word;
        } else if(length(Buf))
            Buf = Buf " " word;
        else
            Buf = indent word;

        str = substr(str, n);
        loc = match(str, /[[:space:]]+/);
    }

    # Append the remainder of str to Buf
    if(length(str)) {
        if(length(Buf) + length(str) + 1 >= Width) {
            Out = Out Buf "\n";
            if(InList) indent = Indent "  ";
            Buf = indent str;
        } else if(length(Buf))
            Buf = Buf " " str;
        else
            Buf = indent str;
    }
}