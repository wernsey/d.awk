#
# TODO: Blockquotes not handled.
#

BEGIN { if(!Width) Width = 80; }

# Preserve headings
/^[[:space:]]*(=|-)+/ {
    Out = Out Buf "\n" $0 "\n";
    Buf = "";
    next;
}

# Preformatted text is sent to the output verbatim
/^(    |\t)+/ && match(last,/^[[:space:]]*$/) {
    Out = Out $0 "\n";
    next;
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
    next;
}

# Handle every other input line
{ last = $0; fmt($0); }

# Write output when done
END { 
    Out = Out Buf;
    print Out; 
}

function fmt(str,          loc,word,indent,n) {
    match(str, /^[[:space:]]+/);
    
    # how much is the current line indented
    indent = substr(str, 1, RLENGTH);
    
    # Trim leading whitespace
    str = substr(str, RLENGTH+1);
    
    # Lines starting with list item characters
    # force a line break in the output
    if(match(str,/^([*+-]|[[:digit:]]\.)/)) {
        Out = Out Buf "\n";
        Buf = ""; indent = indent "  ";
    }
    
    # This implements the simple algorithm from the wikipedia
    # https://en.wikipedia.org/wiki/Line_wrap_and_word_wrap
    # There is a better way. See #Minimum_raggedness on that wiki page.
    # There are other examples at https://www.rosettacode.org/wiki/Word_wrap
    
    loc = match(str, /[[:space:]]+/);
    while(loc) {
        word = substr(str, 1, RSTART-1);
        n = RSTART+RLENGTH;
        
        # Handle forced line breaks
        if(match(str,/(  |[[:space:]]+\\)$/)) {
            Out = Out str "\n";
            n = RSTART+RLENGTH;
        } else {
            # If the buffer + the word exceeds the allowed width
            # then insert a line break. Otherwise, just append the
            # word to the buffer.
            # Also, preserve the indentation.
            if(length(Buf) + length(word) + 1 >= Width) {
                Out = Out Buf "\n" ;
                Buf = indent word;
            } else if(length(Buf))
                Buf = Buf " " word;
            else
                Buf = indent word;
        }
        str = substr(str, n);
        loc = match(str, /[[:space:]]+/);
    }
    
    # Append the remainder of str to Buf
    if(length(str)) {
        if(length(Buf) + length(str) + 1 >= Width) {
            Out = Out Buf "\n" ;
            Buf = indent str;
        } else if(length(Buf))
            Buf = Buf " " str;
        else
            Buf = str;
    }
}