d.awk
=====

An [Awk][] script to generate documentation from [Markdown][]-formatted
comments in C, C++, JavaScript and any other language that uses `/* */` for
multiline comments in its source code.

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
rendered as HTML. Comments may also start with `///`.

A typical use case to bundle the `d.awk` script with your project's source and
to then add a `docs` target to the Makefile:

    docs: api-doc.html
    api-doc.html: header.h d.awk
        $(AWK) -f d.awk $< > $@

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
  * You can specify a language according to Github's [Syntax Highlighting][github-syntax]
    rules, for example ```` ```java ````
  * This requires that you specify `-vPretty=1` on the command line.  \
    (It is disabled by default because the generated HTML uses a third-party script)
  * It uses Google's [code-prettify][] library for the syntax highlighting.   
* [x] GitHub-style task lists
* [MultiMarkdown][]-style footnotes and abbreviations.
* Backslash at the end of a line  \
  forces a line break.

The file [demo.c](demo.c) in the distribution serves as an example, user guide and test
at the same time.

There are additional scripts in the distribution:

 * [mdown.awk](mdown.awk) - Generates HTML from a normal Markdown file.
 * [xtract.awk](xtract.awk) - Extracts the Markdown comments of a source file.
 * [wrap.awk](wrap.awk) - Formats a Markdown text file to fit on a page.

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

# alternatively: awk -f d.awk demo.c > doc.html
```

The file `demo.c` in the distribution provides a demonstration of all the
features and the supported syntax.

Configuration options can be set in the `BEGIN` block of the script, or passed
to the script through Awk's `-v` command-line option:
- `-v Title="My Document Title"` to set the `<title/>` of the HTML
- `-v stylesheet="style.css"` to use a separate file as style sheet.
- `-v TopLinks=1` to have links to the top of the document next to headers.
- `-v Pretty=1` enable Syntax highlighting with Google's [code-prettify][] library.
- `-v HideToCLevel=n` specifies the level of the Table of Contents that should be 
  collapsed by default. For example, a value of 3 means that headers above level 3
  will be collapsed in the Table of Contents initially.
- `-v classic_underscore=1` words_with_underscores behave like old markdown
  where the underscores in the word counts as emphasis. The default behaviour
  is to have `words_like_this` not contain any emphasis.

The stylesheet for the output HTML can also be modified at the bottom of the
script.

### mdown.awk

Creates an HTML document from a Markdown file.

For example, to generate HTML from this `README.md` file, type:

```sh
./mdown.awk README.md > README.html
# awk -f mdown.awk README.md > README.html
```

The command line options are the same as `d.awk`'s.

### xtract.awk

This script extracts the comments from a source file, without processing it as
Markdown.

```sh
./xtract.awk demo.c > demo.md
#aternatively: awk -f xtract.awk demo.c > demo.md
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

## References:

 - <https://en.wikipedia.org/wiki/AWK>
 - <https://en.wikipedia.org/wiki/Markdown>
 - <https://tools.ietf.org/html/rfc7764>
 - <http://daringfireball.net/projects/markdown/syntax>
 - <https://guides.github.com/features/mastering-markdown/>
 - <http://fletcher.github.io/MultiMarkdown-4/syntax>
 - <http://spec.commonmark.org>

## TODO:

Things I'd like to add in the future:

- [x] Syntax highlighting for ```` ``` ````-style code blocks.
  - Using [GitHub's syntax](https://help.github.com/articles/creating-and-highlighting-code-blocks/)
  - Google's code prettify is [here](https://github.com/google/code-prettify)
  - It should be optional (with default `OFF`), because it is going to download additional scripts.
  - This doesn't mean that I can't have the proper classes for the `<code>` blocks, though.
- [ ] The `mdown.awk` script doesn't always like lists at the end of a file.
  - The last item in the list gets duplicated.
  - You can work around this issue by adding a line with a space in it at the end of the file.
  - The other scripts don't have this problem.
- [x] Maybe allow `///` comments to also be used.
  - ~~The problem is that things like lists might not carry over between blocks?~~
  - ~~*Implemented*, but the functionality is limited to inline elements only.~~
- `xtract.awk` is missing a couple of features:
  - [x] `///` comments are not extracted.
    - They are a bit of a minefield because they don't support block-level markdown.
  - [x] `/** Single line comments like this */` aren't extracted.