d.awk - Source code documentation script
========================================

Some [Awk][] scripts to generate documentation from [Markdown][]-formatted
comments in source code.

The [d.awk][] script creates documentation for languages that use `/* */` 
for multiline comments, like C, C++, Java, C#, JavaScript.

The file [hashd.awk][] does the same, but for languages that use `#` symbols
for comments, like Perl, Python, Ruby, and others.

For example, add a comment like this to your source file:

```c
/**
 * My Project
 * ==========
 *
 * This is some _Markdown documentation_ in a `source
 * file`.
 */
int main(int argc, char *argv[]) {
	printf("hello, world");
    return 0;
}
```

Then use Awk to run the `d.awk` script on it like so:

```sh
# Run the script on a file:
./d.awk file.c > doc.html

# alternatively: awk -f d.awk file.c > doc.html
```

The text within the `/** */` comment blocks are parsed as Markdown, and
rendered as HTML. Comments may also start with three slashes: `/// Markdown
here`.

A typical use case to bundle the `d.awk` script with your project's source and
to then add a `docs` target to the Makefile:

    docs: api-doc.html
    api-doc.html: header.h d.awk
        $(AWK) -f d.awk $< > $@

The script can also generate HTML from a normal Markdown document using the `-v
Clean=1` command-line option:

```sh
./d.awk -vPretty=1 -v Clean=1 README.md > README.html
```

There are additional scripts in the distribution:

 * [hashd.awk][] - Like `d.awk`, but for languages that use `#` symbols for comments
 * [mdown.awk][] - Generates HTML from a normal Markdown file.
 * [xtract.awk][] - Extracts the Markdown comments of a source file.
 * [wrap.awk][] - Formats a Markdown text file to fit on a page.

[d.awk]: d.awk
[hashd.awk]: hashd.awk
[mdown.awk]: mdown.awk
[xtract.awk]: xtract.awk
[wrap.awk]: wrap.awk
 
## Features

It supports most of Markdown:
* **Bold**, _italic_ and `monospaced` text.
* Both header styles
* Horizontal rules
* Ordered and Unordered lists
* Code blocks and block quotes
* Hyperlinks and images
* A large number of HTML tags can be embedded in a document

It also supports a number of extensions, mostly based on GitHub syntax:
* ```` ``` ````-style code blocks
  * You can specify a language according to Github's [Syntax
    Highlighting][github-syntax] rules, for example ```` ```java ````
  * This requires that you specify `-vPretty=1` on the command line.  \
    (It is disabled by default because the generated HTML uses a third-party
    script)
  * It uses Google's [code-prettify][] library for the syntax highlighting.
* [x] GitHub-style task lists
* [MultiMarkdown][]-style footnotes and abbreviations.
* Backslash at the end of a line  \
forces a line break.
* There is a special `\![toc]` mode that generates a Table of Contents automatically.

The file [demo.c](demo.c) in the distribution serves as an example, user guide
and test at the same time.

[Awk]: https://en.wikipedia.org/wiki/AWK
[Markdown]: https://en.wikipedia.org/wiki/Markdown
[code-prettify]: https://github.com/google/code-prettify
[github-syntax]: https://help.github.com/articles/creating-and-highlighting-code-blocks/#syntax-highlighting
[MultiMarkdown]: http://fletcher.github.io/MultiMarkdown-4/syntax

## Motivation

`d.awk` is a inspired by the [Javadoc][] and [Doxygen][] tools which generate
HTML documentation from comments in source code.

It is meant for programming languages like C, C++ or JavaScript that use the
`/* */` syntax for comments (it will work with Java and C#, though the
existence of bundled documentation tools for those languages makes it
redundant).

It has two distinguishing features:

Firstly, it is written in the ubiquitous Awk language. You can distribute the
`d.awk` script with your project's source code and your users will be able to
generate documentation without requiring additional 3rd party tools.

Secondly, the documentation use Markdown for text formatting, which has several
advantages:

 * It is well known and widely used.
 * It reads easily and won't clutter your code comments with markup tokens.

[Javadoc]: https://en.wikipedia.org/wiki/Javadoc
[Doxygen]: http://www.stack.nl/~dimitri/doxygen/

## Usage

### d.awk

Comments must start with `/**`, and each line in the comment must start with a
`*` - this is so you can control which comments are included in the
documentation.

To generate documentation from a file `demo.c`, run the `d.awk` script on it
like so:

```sh
./d.awk demo.c > doc.html
```

The file `demo.c` in the distribution provides a demonstration of all the
features and the supported syntax.

Configuration options can be set in the `BEGIN` block of the script, or passed
to the script through Awk's `-v` command-line option:
- `-v Title="My Document Title"` to set the `<title/>` of the HTML
- `-v StyleSheet=style.css` to use a separate file as style sheet.
- `-v TopLinks=1` to have links to the top of the document next to headers.
- `-v Pretty=1` enable Syntax highlighting with Google's [code-prettify][]
  library.
- `-v HideToCLevel=n` specifies the level of the Table of Contents that should
  be collapsed by default. For example, a value of 3 means that headers above
  level 3 will be collapsed in the Table of Contents initially.
- `-v classic_underscore=1` words_with_underscores behave like old markdown
  where the underscores in the word counts as emphasis. The default behaviour
  is to have `words_like_this` not contain any emphasis.

The stylesheet for the output HTML can also be modified at the bottom of the
script.

### hashd.awk

Like `d.awk`, but generates documentation for programming languages that uses
`#` symbols for comments.

For example, to generate an HTML file from the comments at the top of ``
```
./hashd.awk d.awk > demo.html
```

The first comment must start with two `#` symbols. The following is an example
in Python:

```python
##
# My Project
# ==========
#
# This is some _Markdown documentation_ in a `source
# file`.
#
print("Hello, World!")
```

If you have a language that uses a different symbol for comments, you can use
this file and modify the regular expressions at the top to match your language's
comment syntax.

### mdown.awk

Creates an HTML document from a Markdown file.

It is functionally equivalent to using `d.awk` with the `-v Clean=1` command
line option.

For example, to generate HTML from this `README.md` file, type:

```sh
./mdown.awk README.md > README.html
```

The command line options are the same as `d.awk`'s.

### xtract.awk

This script extracts the comments from a source file, without processing it as
Markdown.

```sh
./xtract.awk demo.c > demo.md
```

A use case is to extract the comments from a source file into a new Markdown
document, such as a GitHub wiki page.

### wrap.awk

`wrap.awk` makes a Markdown document more readable by word wrapping long lines
to fit into 80 characters.

For example, to use it on this `README.md` file, run

```sh
cp README.md README.md~
./wrap.awk README.md~ > README.md
```

To specify a different width, use `-v Width=60` from the command line.

## License

The license is officially the MIT license (see the file [LICENSE](LICENSE) for
details), but the individual files may be redistributed with this notice:

    (c) 2016 Werner Stoop
    Copying and distribution of this file, with or without modification,
    are permitted in any medium without royalty provided the copyright
    notice and this notice are preserved. This file is offered as-is,
    without any warranty.

## References

 - <https://en.wikipedia.org/wiki/AWK>
 - <https://en.wikipedia.org/wiki/Markdown>
 - <https://tools.ietf.org/html/rfc7764>
 - <http://daringfireball.net/projects/markdown/syntax>
 - <https://guides.github.com/features/mastering-markdown/>
 - <http://fletcher.github.io/MultiMarkdown-4/syntax>
 - <http://spec.commonmark.org>

## TODO

Things I'd like to add in the future:

- [x] The `mdown.awk` script doesn't always like lists at the end of a file.
  - The last item in the list gets duplicated.
  - You can work around this issue by adding a line with a space in it at the
    end of the file.
  - The other scripts don't have this problem.
- `wrap.awk` adds too much whitespace to code blocks...
