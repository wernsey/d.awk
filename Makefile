AWK ?= awk
# This Makefile just serves as a demonstration of
# what the scripts in this project are and how you
# might use them to generate documentation.

all: demo.html demo-alt.html help.html README.html README-alt.html demo.py.html

# The base case is where you have a source file, like demo.c,
# that contains comments formatted in Markdown. Then you
# just run the d.awk script with your file as input and save
# the output as an HTML file:
demo.html: demo.c d.awk
	$(AWK) -f d.awk $< > $@

# The command could also be written as
#    `./d.awk demo.c > demo.html`
# if you set execute permissions on d.awk.

# The `mdown.awk` script generates HTML files from regular
# Markdown files. You can use it to generate HTML documentation
# from the Markdown files in your project that will have the
# same styles as your source code documentation
README.html: README.md mdown.awk
	$(AWK) -f mdown.awk $< > $@

# The `d.awk` script has a `-vClean=1` option to treat its
# input as a regular Markdown file, rather than a source file.
# An alternative way to generate HTML from your README.md, for
# example, would therefore be:
README-alt.html: README.md d.awk
	$(AWK) -f d.awk -vClean=1 $< > $@

# The `xtract.awk` script extracts Markdown comments from your
# source file without actually rendering it as HTML. This is
# useful for a case where you might want to paste your code
# documentation into, for example, a wiki that accepts markdown
# formatting
demo.md: demo.c xtract.awk
	$(AWK) -f xtract.awk $< > $@

# This is just a test whether `mdown.awk` creates the the same
# output as `d.awk`:
demo-alt.html: demo.md mdown.awk
	$(AWK) -f mdown.awk $< > $@
	
# (There will be a couple of small differences, mostly in how
# whitespace is handled)

# Lastly, `hashd.awk` does the same as `d.awk`, but for languages
# that use hash `#` symbols for comments. 
demo.py.html: demo.py hashd.awk
	$(AWK) -f hashd.awk $< > $@
	
#Here we use it to generate a help file for `d.awk`
help.html: d.awk hashd.awk
	$(AWK) -f hashd.awk $< > $@

.PHONY: clean

clean:
	-rm demo.html demo-alt.html demo.md demo.py.html
	-rm README.html README-alt.html help.html