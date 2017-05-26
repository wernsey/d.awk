/**
 * `comdown.awk` Demonstration
 * ===========================
 * ![toc]
 *
 * This file demonstrates how to comment your code with
 * the `comdown.awk` script. It also serves as a functional test.
 *
 * Comments in your code that are to be included in the output must start with 
 * the sequence `/**`.
 * Other comments and source code are ignored by the script.
 *
   Lines that don't start with *s, like this one, are ignored.
 *
 * Blank lines in the comment separate paragraphs.
 *
 * Two spaces at the end of the line  
 * forces a linebreak. Here is another line<br>break.
 *
 * Headings can be written like so:
 *    Heading 1
 *    =========
 *    Heading 2
 *    ---------
 *
 * Alternatively:
 * ```
 * # Heading 1
 * ## Heading 2
 * ### Heading 3
 * ```
 * # Heading 1
 * ## Heading 2
 * ### Heading 3
 * #### Heading 4
 * ##### Heading 5
 * ###### Heading 6
 * \# symbols after the heading are cleared, so you can also write `## Heading 2 ##`
 * if you prefer. There is a '\\#' escape sequence.
 *
 * Escaping and not escaping ampersands: & &amp; &sect; &#167; &#xA7; and angle brackets: < > &lt; &gt; `&lt;`.
 * This is a number of operators that broke escaping "=", "<>" (alternatively "!="), "<", "<=", ">" and ">=".
 *
 * Horizontal rules:
 *
 * -----
 *
 * * * * * * * * 
 *
 * Block Level Formatting 
 * ----------------------
 * These options are available at the block level.
 * ### Lists 
 * #### Ordered List ####
 *  1. Item 1
 *       1. Item 1.1
 *          1981\. This line started with a number.
 *       1. Item 1.2;
 *          This item consists of multiple lines  
 *          with a forced line break (two spaces at the end of the last line).
 *  1. Item 2
 *         * Item 2.1; List styles can be mixed.
 *         * Item 2.2
 *      
 *           The blank line above contains whitespace, hence a new list is not started
 *           (Paragraphs in lists differ a bit from other markdowns).
 *         * Item 2.3
 *  1. Item 3
 *        1. Item 3.1
 *              1. Item 3.1.1
 *        1. Item 3.2
 *
 * #### Unordered List
 *  - Item 1
 *     + Item 1.1
 *     + Item 1.2
 *  - Item 2
 *       1. Item 2.1; Again, list styles can be mixed.
 *       1. Item 2.2
 *  - Item 3
 *      * Item 3.1
 *      * Item 3.2
 *
 * GitHub-style task lists are also supported:
 *   - [ ] Task 1
 *     - [] Subtask 1a
 *     - [X] Subtask 1b
 *   - [x] Task 2 - **completed.**
 *   - [] Task 3 - the space between the `[` and `]` is necessary.
 *     1. [ ] Subtask 3a
 *     1. [x] Subtask 3b
 *   - [x] ~~Task 4~~ - also completed
 *
 * ### Block Quotes
 * > This is a blockquote. It
 * may span multiple lines.
 * >
 * > Blank lines like the one above separates paragraphs within the quote.
 * >
 * > Unfortunately it can't contain nested quotes lists
 * > and code in this implementation.
 *
 * The empty line above ends the quote.
 *
 * ### Code Blocks
 * Code indented with tabs:
 *	//Some code, indented with a single tab:
 *	int main(int argc, char *argv[]) {
 *		return 0;
 *	}
 *
 * Code indented with spaces:
 *    //Some code, indented with spaces
 *    
 *    int main(int argc, char *argv[]) {
 *        return 0;
 *    }
 * This particular implementation doesn't care about blank lines
 * after the code block.
 *
 * GitHub-style code blocks:
 * ```
 * //Some code, wrapped in ```
 *
 * int main(int argc, char *argv[]) {
 *     return 0;
 * }
 * ```
 * Unfortunately, if you use C/C++ you have to escape your asterisks
 * like **int foo(int \*x, int \*y)** or this **int main(int argc, char \*argv[])**  
 * unless you use backticks: `int main(int argc, char *argv[])`
 *
 * Regression test: The #es in this sample would've caused problems:
 *
 *    # Compile like so:
 *    mvn package
 *    
 *    # Generate Javadocs
 *    mvn javadoc:javadoc
 *
 * This is a diagram:
 *
 *       +-------+     +--------+
 *       |       |     |        |
 *       |  Foo  +----->   Bar  |
 *       | Block |     |  Block |
 *       |       |     |        |
 *       +---^---+     +----+---+
 *           |              |
 *           |              |
 *           |         +----v---+
 *           |         |        |
 *           |         |        |
 *           +---------+        |
 *                     |        |
 *                     +--------+
 *
 * Hyperlinks
 * ----------
 * * Example hyperlink 1: [This link](http://example.com) is inline
 * * Example hyperlink 1B: [This link][link1] is not inline; escape charaters in the url.
 * * Example hyperlink 2: [This link] [link2] and [this one][LINK2] (case insensitive) has a title attribute.
 *   You can also do [link2][].
 * * Example hyperlink 3: [This link <&>][link3] has a title attribute on separate line and
 *   escaped characters in the link text.
 * * Example hyperlink 4: [funny example][funny] in `<angle brackets>`
 * * Example hyperlink 5: [example 5](http://example.com?x=5&y=10 "Example Title <&>") with inline title attribute and
 *   escaped characters in the link description.
 * * Links can be placed inline: <http://www.example.com>.
 * * e-mail addresses get obfuscated: <address@example.com>
 * * Relative links that refer to specific headings are supported.
 *   For example [Block Level Formatting][block-level-formatting] - replace spaces with -, remove all 
 *   other non-alphanumerics and everything lowercase.  
 *   Alternatively [Block Level Formatting][Block Level Formatting] or [ Using HTML in Documents ][]
 * * [This link](http://example.com/some_random_page) has \_underscores\_ where
 *   the usual rules about escaping apply, but [this one][underscores] doesn't.
 *
 * Not links: [foo] and this one \[foo](www.example.com).
 *
 * [link1]: http://example.com?x=5&y=10
 * [link2]: http://example.com/2 (Second Example; Escaped characters: < & >)
 * [link3]: http://example.com/3 
 *         (Third Example <&>)
 * [funny]: <http://example.com/funny> (Link in angle brackets)
 * [underscores]: http://example.com/some_random_page
 *
 * Images 
 * ------
 * 
 * Image syntax `\![Image Alt Text](example.png)`  
 * Escaping images `\![Image Alt Text](example.png)` and links `\[Link Alt Text](example.com)`
 *
 * Images can be encoded as Data URIs: ![Red Dot][reddot]  
 * <sub>The red dot comes from [Wikipedia][datauri]</sub>
 *
 * [dataURI]: https://en.wikipedia.org/wiki/Data_URI_scheme "Data URI scheme"
 * [reddot]: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==
 *
 * Line-Level Formatting
 * ----------------------
 * * \_Emphasized\_ produces _Emphasized_
 *   * A word *containing_nested_underscores* can be treated in one of two ways depending on 
 *     whether the variable `classic_underscore` is in the script.
 *   * A word containing*nested*asterisks will be treated as emphasis.
 * * \*Emphasized\* produces *Emphasized*
 * * \__Strongly Emphasized\__ produces __Strongly Emphasized__
 * * \**Strongly Emphasized\** produces **Strongly Emphasized**
 * * \`Code Block\` produces `Code Block`
 * * \`\`Code Block\`\` produces ``Code Block``
 * * \`\`Code Block with embedded backtick: \` \`\` produces ``Code Block with embedded backtick: ` ``
 * * \~~Strike through\~~ produces ~~Strike through~~
 * * _You **can** mix styles within `other` styles_
 * * But the backtick code blocks cause asterisks and underscores to be ignored:  
 *   `void do_something(Widget *foo, int p, int q, Wotzit *bar, int zoop)`
 * * Whitespace surrounding the * or _ will cause it to be treated as literal:
 *   * _ this text would not be emphasized _ and neither would this * mmmm *
 *   * ** this text would not be emphasized ** and neither would this __ mmmm __
 *
 * Extensions
 * ----------
 * The special tag `\![toc]` can be used to insert a table of contents in the document.
 * Leave a blank line below it to ensure the paragraphs are formatted correctly.
 *
 * [MultiMarkdown][]-style footnotes are supported:
 *  - Here is a reference to the footnote[^footnote][^<http://example.com>].
 *  - Here is an inline footnote[^An _inline_ footnote. **Text** _formatting_ ``works`` 
 *         here as well; Some characters to escape: < & > and <http://example.com>]. 
 *  - Here is a reference to the third footnote[^footnote3].
 *
 * MultiMarkdown's syntax for abbreviations is also supported. 
 * For example HTML, XML and GUI.
 * ```
 * *[HTML]: Hypertext Markup Language
 * *[XML]: eXstensible Markup Language; Escaped characters: < > &
 * *[GUI]: Graphical User Interface
 * ```
 * But only whole words: HTML5 and SXML doesn't get the `<abbr/>` tag.
 * 
 * [^footnote]: This is a footnote; **Text** _formatting_ ``works``. Some characters to escape: < & > 
 * [^footnote3]: This is footnote number 3. This one contains a [hyperlink][link1]
 * [MultiMarkdown]: http://fletcher.github.io/MultiMarkdown-4/syntax
 * *[HTML]: Hypertext Markup Language
 * *[XML]: eXstensible Markup Language; Escaped characters: < > &
 * *[GUI]: Graphical User Interface
 *
 * Another idea borrowed from MultiMarkdown is to have a \
 * space followed by a \ at the end of a line force a line break. \
 * This is useful because I have the habit of trimming trailing spaces.
 *
 * Using HTML in Documents
 * -----------------------
 * ### A HTML Table
 * <table>
 * <tr><th>Column A</th><th>Column B</th><th>Column C</th></tr>
 * <tr><td>Item 1a</td><td>Item 1b</td><td>Item 1c</td></tr>
 * <tr><td>Item 2a</td><td>Item 2b</td><td>Item 2c</td></tr>
 * <tr><td>Item 3a</td><td>Item 3b</td><td>Item 3c</td></tr>
 * <tr><td>Item 4a</td><td>Item 4b</td><td>Item 4c</td></tr>
 * <tr><td>Item 5a</td><td>Item 5b</td><td>Item 5c</td></tr>
 * <tr><td>Item 6a</td><td>Item 6b</td><td>Item 6c</td></tr>
 * </table>
 * 
 * ### A Definitions List
 * <dl>
 * <dt>Item 1</dt>
 * <dd>A description of item 1.</dd>
 * <dt>Item 2</dt>
 * <dd>A description of item 2.</dd>
 * <dt>Item 3</dt>
 * <dd>A description of item 3.</dd>
 * </dl>
 * 
 * ### Some Other Tags
 * Some <b>bold text</b>, some <i>italic text</i>, a <q>quote</q>,
 * a <var class="xxx">variable</var>, <ins>inserted text</ins>, <del>deleted text</del>,
 * a <mark>marked block</mark>, a <cite>[citation]</cite>.
 *
 * A `<div/>` element:
 * <div class="highlight">A `<div/>` element</div>
 *
 * A `<span/>` element:
 * <span class="highlight">A `<span/>` element</span>
 *
 * Not all HTML tags are supported. For example:  
 * <script type="text/javascript">$(function(){alert("GOTCHA!");});</script>
 *
 * This is how you work around the limitations of block quotes:
 * <blockquote>
 * Block quote.
 * <blockquote>
 * Block quote within a block quote.
 * </blockquote>
 * <pre><code>
 * &lt;pre/&gt; block within the blockquote.
 * </code></pre>
 * </blockquote>
 *
 * Lorem Ipsum
 * -----------
 *
 * Some Lorem Ipsum from [lipsum.com](http://www.lipsum.com/) to see how the styles work
 * with large paragraphs:
 *
 * Lorem **ipsum** dolor sit amet, consectetur **adipiscing elit**. In interdum ut nulla suscipit 
 * tincidunt. Mauris sollicitudin consectetur elit sit amet iaculis. Aliquam urna neque, 
 * pretium quis eros non, pellentesque tempus augue. Vestibulum ornare, lacus non sagittis 
 * elementum, est ante placerat dolor, vitae tincidunt orci felis id felis. Etiam id nisl 
 * sed turpis pulvinar condimentum. Etiam neque tortor, sollicitudin id metus sed, mollis 
 * maximus enim. Sed risus ante, suscipit quis ex vitae, consectetur ultricies diam. Nulla 
 * sollicitudin quis purus ornare tempor. Sed rhoncus sapien volutpat neque pretium, nec 
 * dapibus nisl iaculis. Praesent ultrices risus eget purus semper pulvinar sed ut ligula. 
 * Nunc ac nisl neque.
 * 
 * Sed enim enim, fermentum at lectus eu, tincidunt sollicitudin mi. Praesent vel auctor 
 * elit. Etiam ac vulputate nisl. Etiam egestas urna quis velit varius convallis. Vestibulum 
 * sed porta mi. Vestibulum ac dolor eu purus mattis bibendum congue sed nunc. Curabitur sed 
 * venenatis neque. Curabitur et eros ac leo ultrices ultricies vitae ut justo.
 * 
 * Vestibulum viverra venenatis quam, quis faucibus magna commodo hendrerit. Sed at dui et orci 
 * mattis accumsan. Integer vulputate blandit volutpat. Mauris non sem a velit posuere fringilla. 
 * Phasellus id arcu euismod, blandit lectus a, tempus justo. Aenean efficitur, velit nec aliquet 
 * rhoncus, nisi lectus efficitur diam, non dignissim est metus et sem. Sed ornare lacus eget 
 * convallis semper. Fusce malesuada nunc et mauris facilisis consectetur. Pellentesque 
 * consectetur suscipit mauris, eu lobortis nisi consequat nec. Sed sagittis ac ligula sit amet 
 * scelerisque. Curabitur ipsum risus, imperdiet ut pellentesque eu, hendrerit sed erat.
 * 
 * Praesent auctor, lacus quis condimentum interdum, leo orci elementum tellus, nec eleifend 
 * mauris tellus non ipsum. Aenean sit amet congue ante. Morbi ultricies pharetra tortor, a 
 * elementum purus congue laoreet. Fusce varius semper enim, non pretium urna ultricies et. 
 * Aliquam laoreet urna non tristique suscipit. Donec sollicitudin sit amet erat id cursus. 
 * Aliquam nisl nisi, maximus et molestie id, viverra tempor neque. Duis et interdum nisi. 
 * Nullam vulputate sed risus et finibus. Etiam eu leo et mi elementum laoreet vestibulum ut 
 * ipsum. Pellentesque bibendum dictum est, sit amet placerat diam aliquet eu. Phasellus 
 * dignissim tristique lacus a semper. Phasellus nec sollicitudin lectus.
 * 
 * Duis non lectus purus. Sed ornare nulla felis, id suscipit mi suscipit vel. Duis nec ipsum 
 * a arcu posuere vulputate et ut ante. Vivamus vitae erat et tortor varius consequat at sit amet
 * nulla. In rutrum, lacus et posuere auctor, diam sapien varius diam, id **vehicula enim urna vel
 * massa**. Aliquam iaculis volutpat nisi, a ultricies eros tristique eu. Suspendisse ac mattis lectus. 
 * Nunc facilisis massa non maximus cursus. Etiam consequat, magna nec sollicitudin luctus, nisi leo 
 * tincidunt ipsum, vitae suscipit arcu arcu id velit. Mauris auctor faucibus scelerisque.
 */
 
/* This comment is not processed because it doesn't start with the ** */
 
/** Comments on lines by themselves are treated as separate paragraphs. */

//Some text that should not be converted.
int main(int argc, char *argv[]) {
	/** You can put comments anywhere in your code. */
	printf("hello, world");
    return 0;
}