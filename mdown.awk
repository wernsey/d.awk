#! /usr/bin/awk -f
#
# Markdown processor in AWK. It is simplified from d.awk
# https://github.com/wernsey/d.awk
#
# ## References
#
# - <https://tools.ietf.org/html/rfc7764>
# - <http://daringfireball.net/projects/markdown/syntax>
# - <https://guides.github.com/features/mastering-markdown/>
# - <http://fletcher.github.io/MultiMarkdown-4/syntax>
# - <http://spec.commonmark.org>
#
# ## License
#
# (c) 2016-2025 Werner Stoop
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved. This file is offered as-is,
# without any warranty.
#

BEGIN {

    # Configuration options
    if(Css== "") Css = 1;

    if(Highlight== "") Highlight = 1;
    if(Mermaid== "") Mermaid = 1;
    if(MermaidTheme== "") MermaidTheme = "neutral";
    if(Mathjax=="") Mathjax = 1;

    if(HideToCLevel== "") HideToCLevel = 3;
    if(Lang == "") Lang = "en";
    if(Tables == "") Tables = 1;
    #TopLinks = 1;
    #classic_underscore = 1;
    if(MaxWidth=="") MaxWidth="1080px";
    if(NumberHeadings=="") NumberHeadings = 1;
    if(NumberH1s=="") NumberH1s = 0;

    # Definition lists are still experimental, so if they cause problems you can
    # disable them here, and use <dl> <dt> and <dd> tags instead
    if(DefLists=="") DefLists = 1;

    Mode = "p";
    ToC = ""; ToCLevel = 1;
    CSS = init_css(Css);
    for(i = 0; i < 128; i++)
        _ord[sprintf("%c", i)] = i;
    srand();

    # Allowed HTML tags:
    HTML_tags = "^/?(a|abbr|b|blockquote|br|caption|cite|code|col|colgroup|column|dd|del|details|div|dl|dt|em|figcaption|figure|h[[:digit:]]+|hr|i|img|ins|li|mark|ol|p|pre|q|s|samp|small|span|strong|sub|summary|sup|table|tbody|td|tfoot|th|thead|tr|u|ul|var)$";
    
    # Languages supported by the default highlight.js distribution:
    # (They're the languages in the 'Common' section of this page: https://highlightjs.org/download)
    split("bash c cpp csharp css diff go graphql ini java javascript json kotlin less lua makefile " \
          "markdown objectivec perl php-template php plaintext python-repl python r ruby rust scss " \
          "shell sql swift typescript vbnet wasm xml yaml", LangsCommon);
    
    # Languages supported by highlight.js for which additional files are needed:
    split("1c abnf accesslog actionscript ada angelscript apache applescript arcade arduino armasm " \
        "asciidoc aspectj autohotkey autoit avrasm awk axapta basic bnf brainfuck cal capnproto " \
        "ceylon clean clojure clojure-repl cmake coffeescript coq cos crmsh crystal csp d dart " \
        "delphi django dns dockerfile dos dsconfig dts dust ebnf elixir elm erb erlang erlang-repl " \
        "excel fix flix fortran fsharp gams gauss gcode gherkin glsl gml golo gradle groovy haml " \
        "handlebars haskell haxe hsp http hy inform7 irpf90 isbl jboss-cli julia julia-repl lasso " \
        "latex ldif leaf lisp livecodeserver livescript llvm lsl mathematica matlab maxima mel " \
        "mercury mipsasm mizar mojolicious monkey moonscript n1ql nestedtext nginx nim nix " \
        "node-repl nsis ocaml openscad oxygene parser3 pf pgsql pony powershell processing profile " \
        "prolog properties protobuf puppet purebasic q qml reasonml rib roboconf routeros rsl " \
        "ruleslanguage sas scala scheme scilab smali smalltalk sml sqf stan stata step21 stylus " \
        "subunit taggerscript tap tcl thrift tp twig vala vbscript vbscript-html verilog vhdl vim " \
        "wren x86asm xl xquery zephir", LangsExtra);
}

{
    gsub(/\r/,"");
    Out = Out filter($0);
}

!Title { Title = FILENAME; }

END {
	if(Title == "-") Title = "Documentation";
    if(Mode == "ul" || Mode == "ol") {
        while(ListLevel > 1)
            Buf = Buf "\n</" Open[ListLevel--] ">";
        Out = Out tag(Mode, Buf "\n");
    } else if(Mode == "pre") {
        Out = Out end_pre(Buf);
    } else if(Mode == "table") {
        Out = Out end_table();
    } else if(Mode == "blockquote") {
        Out = Out end_blockquote(Buf);
    } else if(Mode == "dl") {
        Out = Out end_dl(Buf);
        pop();
        if(Dl_line) Out = Out filter(Dl_line);
    } else {
        Buf = trim(scrub(Buf));
        if(Buf)
            Out = Out tag(Mode, Buf);
    }

    print "<!DOCTYPE html>\n<html lang=\"" Lang "\"><head>"
    print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">";
    print "<title>" Title "</title>";
    if(StyleSheet)
        print "<link rel=\"stylesheet\" href=\"" StyleSheet "\">";
    else {
        print "<style><!--\n" CSS "\n" \
        ".print-only {display:none}\n"\
        "@media print {\n"\
        "  .no-print { display: none !important;}\n"\
        "  .print-only {display:block;}\n" \
        "  code {font-size: smaller;}\n"\
        "  pre {overflow-x: clip !important;}\n"\
        "}\n"\
        "--></style>";
    }
    if(ToC && match(Out, /!\[toc[-+]?\]/))
        print "<script><!--\n" \
            "function toggle_toc(n) {\n" \
            "    var toc=document.getElementById('table-of-contents-' + n);\n" \
            "    var btn=document.getElementById('btn-text-' + n);\n" \
            "    toc.style.display=(toc.style.display=='none')?'block':'none';\n" \
            "    btn.innerHTML=(toc.style.display=='none')?'&#x25BA;':'&#x25BC;';\n" \
            "}\n" \
            "function toggle_toc_ul(n) {   \n" \
            "    var toc=document.getElementById('toc-ul-' + n);   \n" \
            "    var btn=document.getElementById('toc-btn-' + n);   \n" \
            "    if(toc) {\n" \
            "        toc.style.display=(toc.style.display=='none')?'block':'none';   \n" \
            "        btn.innerHTML=(toc.style.display=='none')?'&#x25BA;':'&#x25BC;';\n" \
            "    }\n" \
            "}\n" \
            "//-->\n</script>";
    if(Highlight && HasHighlight) {
        print "</head><body onload=\"setHljsTheme(window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')\">";
        print "<script>\n" \
              "function setHljsTheme(theme) {\n" \
              "  if(theme=='dark') {\n" \
              "    document.querySelector(\"link[title='dark']\").removeAttribute('disabled');\n" \
              "    document.querySelector(\"link[title='light']\").setAttribute('disabled',true);\n" \
              "  } else {\n" \
              "    document.querySelector(\"link[title='light']\").removeAttribute('disabled');\n" \
              "    document.querySelector(\"link[title='dark']\").setAttribute('disabled',true);\n" \
              "  }\n" \
              "}\n" \
              "</script>"
    } else {
        print "</head><body>";
    }

    if(Css)
        print "<a class=\"dark-toggle no-print\">\n" svg("moon", "", 12) "\n&nbsp;Toggle Dark Mode</a>\n";

    if(Out) {
        Out = fix_footnotes(Out);
        Out = fix_links(Out);
        Out = fix_abbrs(Out);
        Out = make_toc(Out);

        print trim(Out);
        if(footnotes) {
            footnotes = fix_links(footnotes);
            print "<hr><ol class=\"footnotes\">\n" footnotes "</ol>";
        }
    }

    print "<script>\n"\
    "(() => {\n" \
    "  let currentTheme = () => (!prefersDarkScheme.matches && !document.body.classList.contains('dark-theme')) || (prefersDarkScheme.matches && document.body.classList.contains('light-theme')) ? 'light' : 'dark';\n"\
    "  const prefersDarkScheme = window.matchMedia('(prefers-color-scheme: dark)');\n" \
    "  document.querySelector('.dark-toggle').addEventListener('click', function () {\n" \
    "    document.body.classList.toggle(prefersDarkScheme.matches ? 'light-theme' : 'dark-theme');\n" \
    ((Highlight && HasHighlight) ? "    setHljsTheme(currentTheme());\n": "") \
    "  });\n" \
    "  const copyCode = async (event) => { \n" \
    "    let elem = event.target;\n" \
    "    while(!(elem.classList.contains('code-block')))\n" \
    "      elem = elem.parentElement;\n" \
    "    let code = elem.querySelector('code').innerText;\n" \
    "    try {\n" \
    "      await navigator.clipboard.writeText(code);          \n" \
    "      let msg = elem.querySelector('.code-message');\n" \
    "      msg.classList.remove('hidden');\n" \
    "      setTimeout(()=>msg.classList.add('hidden'), 500);           \n" \
    "    } catch (error) {\n" \
    "      console.error(error.message);\n" \
    "    }\n" \
    "  };\n" \
    "  document.querySelectorAll('.code-button').forEach(b => b.addEventListener('click', copyCode));\n";
    
    if(Highlight && HasHighlight) {
        print "  let currentMode = '';\n" \
              "  window.onbeforeprint = () => { currentMode = currentTheme(); setHljsTheme('light'); };\n" \
              "  window.onafterprint = () => setHljsTheme(currentMode);";
    }   
    
    print "})();\n</script>";

    if(Highlight && HasHighlight) {
        tp++;
        print "<link title=\"dark\" rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/styles/atom-one-dark.min.css\" disabled>";
        print "<link title=\"light\" rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/styles/atom-one-light.min.css\" disabled>";
        print "<script src=\"https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/highlight.min.js\"></script>";
        for(lang in AdditionalLangs) {
            print "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/languages/" lang ".min.js\"></script>";
        }
        print "<script>hljs.configure({cssSelector:'pre code.highlight'});hljs.highlightAll();</script>";
    }
    if(Mermaid && HasMermaid) {
        tp++;
        print "<script src=\"https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js\"></script>";
        print "<script>mermaid.initialize({ startOnLoad: true, theme:'" MermaidTheme "'});</script>";
    }
    if(Mathjax && HasMathjax) {
        tp++;
        print "<script>MathJax={tex:{inlineMath:[['$','$'],['\\\\(','\\\\)']]},svg:{fontCache:'global'}};</script>";
        print "<script src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\" type=\"text/javascript\" id=\"MathJax-script\" async></script>";
    }
    
    print "<details class=\"credits no-print\">";
    print "<summary>d.awk</summary>";
    print "<p>Documentation generated with <a href=\"https://github.com/wernsey/d.awk\">d.awk</a></p>";
    if(tp) {
        print "<p>Third party libraries:</p>";
        print "<table style=\"border-collapse: collapse;\">";
        print "<tr><th>Library</th><th>Author</th><th>License</th></tr>";
        if(Highlight && HasHighlight) {
            print "<tr>";
            print "<td><a href=\"https://highlightjs.org/\">highlight.js</a></td>";
            print "<td>Ivan Sagalaev and <a href=\"https://github.com/highlightjs/highlight.js/blob/main/CONTRIBUTORS.md\">contributors</a></td>";
            print "<td><a href=\"https://raw.githubusercontent.com/highlightjs/highlight.js/refs/heads/main/LICENSE\">BSD 3-Clause</a></td>";
            print "</tr>";
        }
        if(Mermaid && HasMermaid) {
            print "<tr>";
            print "<td><a href=\"https://mermaid.js.org/\">Mermaid</a></td>";
            print "<td>Knut Sveidqvist and <a href=\"https://github.com/mermaid-js/mermaid/graphs/contributors\">contributors</a></td>";
            print "<td><a href=\"https://raw.githubusercontent.com/mermaid-js/mermaid/refs/heads/develop/LICENSE\">MIT License</a></td>";
            print "</tr>";
        }
        if(Mathjax && HasMathjax) {
            print "<tr>";
            print "<td><a href=\"https://www.mathjax.org/\">MathJax</a></td>";
            print "<td>Davide P. Cervone and <a href=\"https://github.com/mathjax/MathJax-src/graphs/contributors\">contributors</a></td>";
            print "<td><a href=\"https://raw.githubusercontent.com/mathjax/MathJax-src/refs/heads/master/LICENSE\">Apache 2.0</a></td>";
            print "</tr>";
        }
        print "</table>";
    }
    print "</details>";
    
    print "</body></html>"
}

function escape(st) {
    gsub(/&/, "\\&amp;", st);
    gsub(/</, "\\&lt;", st);
    gsub(/>/, "\\&gt;", st);
    return st;
}
function strip_tags(st) {
    gsub(/<\/?[^>]+>/,"",st);
    return st;
}
function trim(st) {
    sub(/^[[:space:]]+/, "", st);
    sub(/[[:space:]]+$/, "", st);
    return st;
}
function filterM(st,     n,i,res) {
    n = split(st, Lines, /\n/);
    for(i = 1; i <= n; i++) {
        res = res filter(Lines[i]);
    }
    return res;
}
function filter(st,       res,tmp, linkdesc, url, delim, edelim, name, def, plang, mmaid, cols, i) {
    if(Mode == "p") {
        if(match(st, /^[[:space:]]*\[[-._[:alnum:][:space:]]+\]:/)) {
            linkdesc = ""; LastLink = 0;
            match(st,/\[.*\]/);
            LinkRef = tolower(substr(st, RSTART+1, RLENGTH-2));
            st = substr(st, RSTART+RLENGTH+2);
            match(st, /[^[:space:]]+/);
            url = substr(st, RSTART, RLENGTH);
            st = substr(st, RSTART+RLENGTH+1);
            if(match(url, /^<.*>/))
                url = substr(url, RSTART+1, RLENGTH-2);
            if(match(st, /["'(]/)) {
                delim = substr(st, RSTART, 1);
                edelim = (delim == "(") ? ")" : delim;
                if(match(st, delim ".*" edelim))
                    linkdesc = substr(st, RSTART+1, RLENGTH-2);
            }
            LinkUrls[LinkRef] = escape(url);
            if(!linkdesc) LastLink = 1;
            LinkDescs[LinkRef] = escape(linkdesc);
            return;
        } else if(LastLink && match(st, /^[[:space:]]*["'(]/)) {
            match(st, /["'(]/);
            delim = substr(st, RSTART, 1);
            edelim = (delim == "(") ? ")" : delim;
            st = substr(st, RSTART);
            if(match(st, delim ".*" edelim))
                LinkDescs[LinkRef] = escape(substr(st,RSTART+1,RLENGTH-2));
            LastLink = 0;
            return;
        } else if(match(st, /^[[:space:]]*\[\^[-._[:alnum:][:space:]]+\]:[[:space:]]*/)) {
            match(st, /\[\^[[:alnum:]]+\]:/);
            name = substr(st, RSTART+2,RLENGTH-4);
            def = substr(st, RSTART+RLENGTH+1);
            Footnote[tolower(name)] = scrub(def);
            return;
        } else if(match(st, /^[[:space:]]*\*\[[[:alnum:]]+\]:[[:space:]]*/)) {
            match(st, /\[[[:alnum:]]+\]/);
            name = substr(st, RSTART+1,RLENGTH-2);
            def = substr(st, RSTART+RLENGTH+2);
            Abbrs[toupper(name)] = def;
            return;
        } else if(match(st, /^((    )| *\t)/) || match(st, /^[[:space:]]*```+[[:alnum:]]*/)) {
            Preterm = trim(substr(st, RSTART,RLENGTH));
            st = substr(st, RSTART+RLENGTH);
            if(Buf) res = tag("p", scrub(Buf));
            Buf = st;
            push("pre");
        } else if(!trim(Prev) && match(st, /^[[:space:]]*[*-][[:space:]]*[*-][[:space:]]*[*-][-*[:space:]]*$/)) {
            if(Buf) res = tag("p", scrub(Buf));
            Buf = "";
            res = res "<hr>\n";
        } else if(match(st, /^[[:space:]]*===+[[:space:]]*$/)) {
            Buf = trim(substr(Buf, 1, length(Buf) - length(Prev) - 1));
            if(Buf) res= tag("p", scrub(Buf));
            if(Prev) res = res heading(1, scrub(Prev));
            Buf = "";
        } else if(match(st, /^[[:space:]]*---+[[:space:]]*$/)) {
            Buf = trim(substr(Buf, 1, length(Buf) - length(Prev) - 1));
            if(Buf) res = tag("p", scrub(Buf));
            if(Prev) res = res heading(2, scrub(Prev));
            Buf = "";
        } else if(match(st, /^[[:space:]]*#+/)) {
            sub(/#+[[:space:]]*$/, "", st);
            match(st, /#+/);
            ListLevel = RLENGTH;
            tmp = substr(st, RSTART+RLENGTH);
            if(Buf) res = tag("p", scrub(Buf));
            res = res heading(ListLevel, scrub(trim(tmp)));
            Buf = "";
        } else if(match(st, /^[[:space:]]*>/)) {
            if(Buf) res = tag("p", scrub(Buf));
            Buf = scrub(trim(substr(st, RSTART+RLENGTH)));
            push("blockquote");
        } else if(Tables && match(st, /.*\|(.*\|)+/)) {
            if(Buf) res = tag("p", scrub(Buf));
            Row = 1;
            for(i = 1; i <= MaxCols; i++)
                Align[i] = "";
            process_table_row(st);
            push("table");
        } else if(match(st, /^[[:space:]]*([*+-]|[[:digit:]]+\.)[[:space:][]/)) {
            if(Buf) res = tag("p", scrub(Buf));
            Buf="";
            match(st, /^[[:space:]]*/);
            ListLevel = 1;
            indent[ListLevel] = RLENGTH;
            Open[ListLevel]=match(st, /^[[:space:]]*[*+-][[:space:]]*/)?"ul":"ol";
            push(Open[ListLevel]);
            res = res filter(st);
        } else if(DefLists && match(st, /^[[:space:]]*:/)) {
            res = "";
            Buf = Buf st "\n";
            Dl_state=1;
            Dl_line = "";
            push("dl");
        } else if(match(st, /^[[:space:]]*$/)) {
            if(trim(Buf)) {
                res = tag("p", scrub(trim(Buf)));
                Buf = "";
            }
        } else
            Buf = Buf st "\n";
        LastLink = 0;
    } else if(Mode == "blockquote") {
        if(match(st, /^[[:space:]]*>[[:space:]]*$/))
            Buf = Buf "\n</p><p>";
        else if(match(st, /^[[:space:]]*>/))
            Buf = Buf "\n" scrub(trim(substr(st, RSTART+RLENGTH)));
        else if(match(st, /^[[:space:]]*$/)) {
            res = end_blockquote(Buf);
            pop();
            res = res filter(st);
        } else
            Buf = Buf st;
    } else if(Mode == "table") {
        if(match(st, /.*\|(.*\|)+/)) {
            process_table_row(st);
        } else {
            res = end_table();
            pop();
            res = res filter(st);
        }
    } else if(Mode == "pre") {
        if(!Preterm && match(st, /^((    )| *\t)/) || Preterm && !match(st, /^[[:space:]]*```+/))
            Buf = Buf ((Buf)?"\n":"") substr(st, RSTART+RLENGTH);
        else {
            gsub(/\t/,"    ",Buf);
            res = end_pre(Buf);
            pop();
            if(Preterm) sub(/^[[:space:]]*```+[[:alnum:]]*/,"",st);
            res = res filter(st);
        }
    } else if(Mode == "ul" || Mode == "ol") {
        if(ListLevel == 0 || match(st, /^[[:space:]]*$/) && (RLENGTH <= indent[1])) {
            while(ListLevel > 1)
                Buf = Buf "\n</" Open[ListLevel--] ">";
            res = tag(Mode, "\n" Buf "\n");
            pop();
        } else {
            if(match(st, /^[[:space:]]*([*+-]|[[:digit:]]+\.)/)) {
                tmp = substr(st, RLENGTH+1);
                match(st, /^[[:space:]]*/);
                if(RLENGTH > indent[ListLevel]) {
                    indent[++ListLevel] = RLENGTH;
                    if(match(st, /^[[:space:]]*[*+-]/))
                        Open[ListLevel] = "ul";
                    else
                        Open[ListLevel] = "ol";
                    Buf = Buf "\n<" Open[ListLevel] ">";
                } else while(RLENGTH < indent[ListLevel])
                    Buf = Buf "\n</" Open[ListLevel--] ">";
                if(match(tmp,/^[[:space:]]*\[[xX[:space:]]\]/)) {
                    st = substr(tmp,RLENGTH+1);
                    tmp = tolower(substr(tmp,RSTART,RLENGTH));
                    Buf = Buf "<li><input type=\"checkbox\" " (index(tmp,"x")?"checked":"") " disabled>" scrub(st);
                } else
                    Buf = Buf "<li>" scrub(tmp);
            } else if(match(st, /^[[:space:]]*$/)){
                Buf = Buf "<br>\n";
            } else {
                sub(/^[[:space:]]+/,"",st);
                Buf = Buf "\n" scrub(st);
            }
        }
    } else if(Mode == "dl") {
        if(Dl_state == 1) {
            if(match(st, /^[[:space:]]*:/)) {
                Buf = Buf "\n" st;
            } else if(match(st, /^[[:space:]]*$/)) {
                Buf = Buf "\n";
                Dl_state = 3;
            } else if(match(st, /^(   |\t)[[:space:]]+[^[:space:]]/)) {
                Buf = Buf "\n" st;
            } else {
                Buf = Buf "\n" st;
                Dl_state = 2;
            }
        } else if(Dl_state == 2) {
            if(match(st, /^[[:space:]]*:/)) {
                Buf = Buf "\n" st;
                Dl_state = 1;
            } else {
                res = end_dl(Buf);
                pop();
                res = res filter(st);
            }
        } else if(Dl_state == 3) {
            if(match(st, /^(   |\t)[[:space:]]+[^[:space:]]/)) {
                Buf = Buf "\n" st;
                Dl_state = 1;
            } else if(!match(st, /^[[:space:]]*$/)) {
                Dl_line = Dl_line "\n" st;
                Dl_state = 4;
            } else {
                Buf = Buf "\n";
            }
        } else if(Dl_state == 4) {
            if(match(st, /^[[:space:]]*:/)) {
                Buf = Buf "\n" Dl_line "\n" st;
                Dl_line = "";
                Dl_state = 1;
            } else {
                res = end_dl(Buf);
                pop();
                res = res filterM(Dl_line "\n" st);
            }
        }
    }
    Prev = st;
    return res;
}
function scrub(st,    mp, ms, me, r, p, tg, a, tok) {
    gsub(/<!--.*-->/,"",st);
    sub(/  $/,"<br>\n",st);
    gsub(/(  |[[:space:]]+\\)\n/,"<br>\n",st);
    gsub(/(  |[[:space:]]+\\)$/,"<br>\n",st);
    while(match(st, /(__?|\*\*?|~~|`+|\$+|\\\(|[&><\\])/)) {
        a = substr(st, 1, RSTART-1);
        mp = substr(st, RSTART, RLENGTH);
        ms = substr(st, RSTART-1,1);
        me = substr(st, RSTART+RLENGTH, 1);
        p = RSTART+RLENGTH;

        if(!classic_underscore && match(mp,/_+/)) {
            if(match(ms,/[[:alnum:]]/) && match(me,/[[:alnum:]]/)) {
                tg = substr(st, 1, index(st, mp));
                r = r tg;
                st = substr(st, index(st, mp) + 1);
                continue;
            }
        }
        st = substr(st, p);
        r = r a;
        ms = "";

        if(mp == "\\") {
            if(match(st, /^!?\[/)) {
                r = r "\\" substr(st, RSTART, RLENGTH);
                st = substr(st, 2);
            } else if(match(st, /^(\*\*|__|~~|`+)/)) {
                r = r substr(st, 1, RLENGTH);
                st = substr(st, RLENGTH+1);
            } else {
                r = r substr(st, 1, 1);
                st = substr(st, 2);
            }
            continue;
        } else if(mp == "_" || mp == "*") {
            if(match(me,/[[:space:]]/)) {
                r = r mp;
                continue;
            }
            p = index(st, mp);
            while(p && match(substr(st, p-1, 1),/[\\[:space:]]/)) {
                ms = ms substr(st, 1, p-1) mp;
                st = substr(st, p + length(mp));
                p = index(st, mp);
            }
            if(!p) {
                r = r mp ms;
                continue;
            }
            ms = ms substr(st,1,p-1);
            r = r itag("em", scrub(ms));
            st = substr(st,p+length(mp));
        } else if(mp == "__" || mp == "**") {
            if(match(me,/[[:space:]]/)) {
                r = r mp;
                continue;
            }
            p = index(st, mp);
            while(p && match(substr(st, p-1, 1),/[\\[:space:]]/)) {
                ms = ms substr(st, 1, p-1) mp;
                st = substr(st, p + length(mp));
                p = index(st, mp);
            }
            if(!p) {
                r = r mp ms;
                continue;
            }
            ms = ms substr(st,1,p-1);
            r = r itag("strong", scrub(ms));
            st = substr(st,p+length(mp));
        } else if(mp == "~~") {
            p = index(st, mp);
            if(!p) {
                r = r mp;
                continue;
            }
            while(p && substr(st, p-1, 1) == "\\") {
                ms = ms substr(st, 1, p-1) mp;
                st = substr(st, p + length(mp));
                p = index(st, mp);
            }
            ms = ms substr(st,1,p-1);
            r = r itag("del", scrub(ms));
            st = substr(st,p+length(mp));
        } else if(match(mp, /`+/)) {
            p = index(st, mp);
            if(!p) {
                r = r mp;
                continue;
            }
            ms = substr(st,1,p-1);
            r = r itag("code", escape(ms));
            st = substr(st,p+length(mp));
        } else if(Mathjax && match(mp, /\$+/)) {
            tok = substr(mp, RSTART, RLENGTH);
            p = index(st, mp);
            if(!p) {
                r = r mp;
                continue;
            }
            ms = substr(st,1,p-1);
            r = r tok escape(ms) tok;
            st = substr(st,p+length(mp));
            HasMathjax = 1;
        } else if(Mathjax && mp=="\\(") {
            p = index(st, "\\)");
            if(!p) {
                r = r mp;
                continue;
            }
            ms = substr(st,1,p-1);
            r = r "\\(" escape(ms) "\\)";
            st = substr(st,p+length(mp));
            HasMathjax = 1;
        } else if(mp == ">") {
            r = r "&gt;";
        } else if(mp == "<") {

            p = index(st, ">");
            if(!p) {
                r = r "&lt;";
                continue;
            }
            tg = substr(st, 1, p - 1);
            if(match(tg,/^[[:alpha:]]+[[:space:]]/)) {
                a = trim(substr(tg,RSTART+RLENGTH-1));
                tg = substr(tg,1,RLENGTH-1);
            } else
                a = "";

            if(match(tolower(tg), HTML_tags)) {
                if(!match(tg, /\//)) {
                    if(match(a, /class="/)) {
                        sub(/class="/, "class=\"dawk-ex ", a);
                    } else {
                        if(a)
                            a = a " class=\"dawk-ex\""
                        else
                            a = "class=\"dawk-ex\""
                    }
                    r = r "<" tg " " a ">";
                } else
                    r = r "<" tg ">";
            } else if(match(tg, "^[[:alpha:]]+://[[:graph:]]+$")) {
                if(!a) a = tg;
                r = r "<a class=\"normal\" href=\"" tg "\">" a "</a>";
            } else if(match(tg, "^[[:graph:]]+@[[:graph:]]+$")) {
                if(!a) a = tg;
                r = r "<a class=\"normal\" href=\"" obfuscate("mailto:" tg) "\">" obfuscate(a) "</a>";
            } else {
                r = r "&lt;";
                continue;
            }

            st = substr(st, p + 1);
        } else if(mp == "&") {
            if(match(st, /^[#[:alnum:]]+;/)) {
                r = r "&" substr(st, 1, RLENGTH);
                st = substr(st, RLENGTH+1);
            } else {
                r = r "&amp;";
            }
        }
    }
    return r st;
}

function push(newmode) {Stack[StackTop++] = Mode; Mode = newmode;}
function pop() {Mode = Stack[--StackTop];Buf = ""; return Mode;}
function heading(level, st,       res, href, u, text) {
    if(level > 6) level = 6;
    st = trim(st);
    href = tolower(st);
    href = strip_tags(href);
    gsub(/[^-_ [:alnum:]]+/, "", href);
    gsub(/[[:space:]]/, "-", href);
    if(TitleUrls[href]) {
        for(u = 1; TitleUrls[href "-" u]; u++);
        href = href "-" u;
    }
    TitleUrls[href] = "#" href;

    text = "<a href=\"#" href "\" class=\"header\">" st "&nbsp;" svg("link") "</a>" (TopLinks?"&nbsp;&nbsp;<a class=\"top\" title=\"Return to top\" href=\"#\">&#8593;&nbsp;Top</a>":"");

    res = tag("h" level, text, "id=\"" href "\"");
    for(;ToCLevel < level; ToCLevel++) {
        ToC_ID++;
        if(ToCLevel < HideToCLevel) {
            ToC = ToC "<a class=\"toc-button no-print\" id=\"toc-btn-" ToC_ID "\" onclick=\"toggle_toc_ul('" ToC_ID "')\">&#x25BC;</a>";
            ToC = ToC "<ul class=\"toc toc-" ToCLevel "\" id=\"toc-ul-" ToC_ID "\">";
        } else {
            ToC = ToC "<a class=\"toc toc-button no-print\" id=\"toc-btn-" ToC_ID "\" onclick=\"toggle_toc_ul('" ToC_ID "')\">&#x25BA;</a>";
            ToC = ToC "<ul style=\"display:none;\" class=\"toc toc-" ToCLevel "\" id=\"toc-ul-" ToC_ID "\">";
        }
    }
    for(;ToCLevel > level; ToCLevel--)
        ToC = ToC "</ul>";
    ToC = ToC "<li class=\"toc-" level "\"><a class=\"toc toc-" level "\" href=\"#" href "\">" st "</a>\n";
    ToCLevel = level;
    return res;
}
function process_table_row(st       ,cols, i) {
    if(match(st, /^[[:space:]]*\|/))
        st = substr(st, RSTART+RLENGTH);
    if(match(st, /\|[[:space:]]*$/))
        st = substr(st, 1, RSTART - 1);
    st = trim(st);

    if(match(st, /^([[:space:]:|]|---+)*$/)) {
        IsHeaders[Row-1] = 1;
        cols = split(st, A, /[[:space:]]*\|[[:space:]]*/)
        for(i = 1; i <= cols; i++) {
            if(match(A[i], /^:-*:$/))
                Align[i] = "center";
            else if(match(A[i], /^-*:$/))
                Align[i] = "right";
            else if(match(A[i], /^:-*$/))
                Align[i] = "left";
        }
        return;
    }

    cols = split(st, A, /[[:space:]]*\|[[:space:]]*/);
    for(i = 1; i <= cols; i++) {
        Table[Row, i] = A[i];
    }
    NCols[Row] = cols;
    if(cols > MaxCols)
        MaxCols = cols;
    IsHeaders[Row] = 0;
    Row++;
}
function end_table(         r,c,t,a,s) {
    for(r = 1; r < Row; r++) {
        t = IsHeaders[r] ? "th" : "td"
        s = s "<tr>"
        for(c = 1; c <= NCols[r]; c++) {
            a = Align[c];
            if(a)
                s = s "<" t " align=\"" a "\">" scrub(Table[r,c]) "</" t ">"
            else
                s = s "<" t ">" scrub(Table[r,c]) "</" t ">"
        }
        s = s "</tr>\n"
    }
    return tag("table", s, "class=\"da\"");
}
function end_pre(buffer,         res, plang, mmaid) {
    if(length(trim(buffer)) > 0) {
        plang = ""; mmaid=0;
        if(match(Preterm, /^[[:space:]]*```+/)) {
            plang = trim(substr(Preterm, RSTART+RLENGTH));
            if(plang) {
                if(plang == "mermaid") {
                    mmaid = 1;
                    HasMermaid = 1;
                } else {
                    HasHighlight = 1;
                    if(plang == "auto")
                        plang = "class=\"highlight\"";
                    else {
                        if(language_supported(plang)) {
                        plang = "class=\"highlight language-" plang "\"";
                        } else {
                            plang = "class=\"nohighlight\"";
                        }
                    }
                }
            }
        }
        if(mmaid && Mermaid)
            res = tag("div", buffer, "class=\"mermaid\"");
        else {
            if(!plang) plang = "class=\"nohighlight\"";
            res = tag("pre", tag("code", escape(buffer), plang));
            if(Css)
                res = tag("div", tag("div", tag("span", "Copied","class=\"code-message hidden\"") tag("span", svg("copy") ,"class=\"code-button\""), "class=\"code-toolbar no-print\"") res, "class=\"code-block\"");
        }
    }
    return res;
}
function end_blockquote(buffer,        tmp) {
    if(match(buffer, /^[[:space:]]*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/)) {
        tmp = tolower(trim(substr(buffer, RSTART, RLENGTH)));
        buffer = substr(buffer, RSTART+RLENGTH);
        gsub(/[^[:alpha:]]/,"",tmp);
        return tag("blockquote", tag("p", svg(tmp, icon_color(tmp)) "&nbsp;" toupper(substr(tmp,0,1)) substr(tmp,2) , "class=\"alert-head\"") tag("p", trim(buffer)), "class=\"alert alert-" tmp "\"");
    }
    return tag("blockquote", tag("p", trim(buffer)));
}
function end_dl(buffer,     n,i,dd,res) {
    gsub(/\n\n+/, "\n\n", buffer);
    n = split(trim(buffer), Dl_Rows, /\n/);
    for(i = 1; i <= n; i++) {
        if(match(Dl_Rows[i], /^[[:space:]]:[[:space:]]/)) {
            if(dd) res = res tag("dd", tag("p", scrub(dd)));
            sub(/^[[:space:]]:[[:space:]]/,"", Dl_Rows[i]);
            dd = Dl_Rows[i];
        } else if(match(Dl_Rows[i], /^(   |\t)[[:space:]]+[^[:space:]]/)) {
            if(dd) {
                dd = dd "\n" trim(Dl_Rows[i]);
        } else {
                res = res tag("dt", scrub(Dl_Rows[i]));
        }
        } else if(match(Dl_Rows[i], /^$/)) {
            if(dd) dd = dd "</p><p>";
        } else {
            if(dd) {
                res = res tag("dd", tag("p", scrub(dd)));
                dd = "";
        }
            res = res tag("dt", scrub(Dl_Rows[i]));
        }
    }
    if(dd) res = res tag("dd", tag("p", scrub(dd)));
    return tag("dl", res);
}
function make_toc(st,              r,p,dis,t,n,tocBody) {
    if(!ToC) return st;
    for(;ToCLevel > 1;ToCLevel--)
        ToC = ToC "</ul>";

    tocBody = "<ul class=\"toc toc-1\">" ToC "</ul>\n";

    p = match(st, /!\[toc[-+]?\]/);
    while(p) {
        if(substr(st,RSTART-1,1) == "\\") {
            r = r substr(st,1,RSTART-2) substr(st,RSTART,RLENGTH);
            st = substr(st,RSTART+RLENGTH);
            p = match(st, /!\[toc[-+]?\]/);
            continue;
        }

        ++n;
        dis = index(substr(st,RSTART,RLENGTH),"+");
        t = "<details id=\"table-of-contents\" class=\"no-print\">\n<summary id=\"toc-button-" n "\" class=\"toc-button\">Contents</summary>\n" \
            tocBody "</details>";
        t = t "\n<div class=\"print-only\">" tocBody "</div>"
        r = r substr(st,1,RSTART-1);
        r = r t;
        st = substr(st,RSTART+RLENGTH);
        p = match(st, /!\[toc[-+]?\]/);
    }
    return r st;
}
function fix_links(st,          lt,ld,lr,url,img,res,rx,pos,pre) {
    do {
        pre = match(st, /<(pre|code)>/); # Don't substitute in <pre> or <code> blocks
        pos = match(st, /\[[^\]]+\]/);
        if(!pos)break;
        if(pre && pre < pos) {
            match(st, /<\/(pre|code)>/);
            res = res substr(st,1,RSTART+RLENGTH);
            st = substr(st, RSTART+RLENGTH+1);
            continue;
        }
        img=substr(st,RSTART-1,1)=="!";
        if(substr(st, RSTART-(img?2:1),1)=="\\") {
            res = res substr(st,1,RSTART-(img?3:2));
            if(img && substr(st,RSTART,RLENGTH)=="[toc]")res=res "\\";
            res = res substr(st,RSTART-(img?1:0),RLENGTH+(img?1:0));
            st = substr(st, RSTART + RLENGTH);
            continue;
        }
        res = res substr(st, 1, RSTART-(img?2:1));
        rx = substr(st, RSTART, RLENGTH);
        st = substr(st, RSTART+RLENGTH);
        if(match(st, /^[[:space:]]*\([^)]+\)/)) {
            lt = substr(rx, 2, length(rx) - 2);
            match(st, /\([^)]+\)/);
            url = substr(st, RSTART+1, RLENGTH-2);
            st = substr(st, RSTART+RLENGTH);
            ld = "";
            if(match(url,/[[:space:]]+["']/)) {
                ld = url;
                url = substr(url, 1, RSTART - 1);
                match(ld,/["']/);
                delim = substr(ld, RSTART, 1);
                if(match(ld,delim ".*" delim))
                    ld = substr(ld, RSTART+1, RLENGTH-2);
            }  else ld = "";
            if(img)
                res = res "<img src=\"" url "\" title=\"" ld "\" alt=\"" lt "\">";
            else
                res = res "<a class=\"normal\" href=\"" url "\" title=\"" ld "\">" lt "</a>";
        } else if(match(st, /^[[:space:]]*\[[^\]]*\]/)) {
            lt = substr(rx, 2, length(rx) - 2);
            match(st, /\[[^\]]*\]/);
            lr = trim(tolower(substr(st, RSTART+1, RLENGTH-2)));
            if(!lr) {
                lr = tolower(trim(lt));
                if(LinkDescs[lr]) lt = LinkDescs[lr];
            }
            st = substr(st, RSTART+RLENGTH);
            url = LinkUrls[lr];
            ld = LinkDescs[lr];
            if(img)
                res = res "<img src=\"" url "\" title=\"" ld "\" alt=\"" lt "\">";
            else if(url)
                res = res "<a class=\"normal\" href=\"" url "\" title=\"" ld "\">" lt "</a>";
            else
                res = res "[" lt "][" lr "]";
        } else
            res = res (img?"!":"") rx;
    } while(pos > 0);
    return res st;
}
function fix_footnotes(st,         r,p,n,i,d,fn,fc) {
    p = match(st, /\[\^[^\]]+\]/);
    while(p) {
        if(substr(st,RSTART-2,1) == "\\") {
            r = r substr(st,1,RSTART-3) substr(st,RSTART,RLENGTH);
            st = substr(st,RSTART+RLENGTH);
            p = match(st, /\[\^[^\]]+\]/);
            continue;
        }
        r = r substr(st,1,RSTART-1);
        d = substr(st,RSTART+2,RLENGTH-3);
        n = tolower(d);
        st = substr(st,RSTART+RLENGTH);
        if(Footnote[tolower(n)]) {
            if(!fn[n]) fn[n] = ++fc;
            d = Footnote[n];
        } else {
            Footnote[n] = scrub(d);
            if(!fn[n]) fn[n] = ++fc;
        }
        footname[fc] = n;
        d = strip_tags(d);
        if(length(d) > 20) d = substr(d,1,20) "&hellip;";
        r = r "<sup title=\"" d "\"><a href=\"#footnote-" fn[n] "\" id=\"footnote-pos-" fn[n] "\" class=\"footnote\">[" fn[n] "]</a></sup>";
        p = match(st, /\[\^[^\]]+\]/);
    }
    for(i=1;i<=fc;i++)
        footnotes = footnotes "<li id=\"footnote-" i "\">" Footnote[footname[i]] \
            "<a title=\"Return to Document\" class=\"footnote-back\" href=\"#footnote-pos-" i \
            "\">&nbsp;&nbsp;&#8630;&nbsp;Back</a></li>\n";
    return r st;
}
function fix_abbrs(str,         st,k,r,p) {
    for(k in Abbrs) {
        r = "";
        st = str;
        t = escape(Abbrs[toupper(k)]);
        gsub(/&/,"\\&", t);
        p = match(st,"[^[:alnum:]]" k "[^[:alnum:]]");
        while(p) {
            r = r substr(st, 1, RSTART);
            r = r "<abbr title=\"" t "\">" k "</abbr>";
            st = substr(st, RSTART+RLENGTH-1);
            p = match(st,"[^[:alnum:]]" k "[^[:alnum:]]");
        }
        str = r st;
    }
    return str;
}
function tag(t, body, attr) {
    if(attr)
        attr = " " trim(attr);
    # https://www.w3.org/TR/html5/grouping-content.html#the-p-element
    if(t == "p" && (match(body, /<\/?(div|table|blockquote|dl|ol|ul|h[[:digit:]]|hr|pre)[>[:space:]]/))|| (match(body,/!\[toc\]/) && substr(body, RSTART-1,1) != "\\"))
        return "<" t attr ">" body "\n";
    else
        return "<" t attr ">" body "</" t ">\n";
}
function itag(t, body) {
    return "<" t ">" body "</" t ">";
}
function language_supported(lang) {
    for(l in LangsCommon) {
        if(LangsCommon[l] == lang) return 1;
    }
    for(l in LangsExtra) {
        if(LangsExtra[l] == lang) { 
            AdditionalLangs[lang]++;
            return 1;
        }
    }
    return 0;
}
function obfuscate(e,     r,i,t,o) {
    for(i = 1; i <= length(e); i++) {
        t = substr(e,i,1);
        r = int(rand() * 100);
        if(r > 50)
            o = o sprintf("&#x%02X;", _ord[t]);
        else if(r > 10)
            o = o sprintf("&#%d;", _ord[t]);
        else
            o = o t;
    }
    return o;
}
function init_css(Css,             css,ss,hr,bg1,bg2,bg3,bg4,ff,fs,i,lt,dt,pt) {
    if(Css == "0") return "";

    css["body"] = "color:var(--color);background:var(--background);font-family:%font-family%;font-size:%font-size%;line-height:1.5em;" \
                "padding:1em 2em;width:80%;max-width:%maxwidth%;margin:0 auto;min-height:100%;float:none;";
    css["h1"] = "border-bottom:1px solid var(--heading);padding:0.3em 0.1em;";
    css["h1 a"] = "color:var(--heading);";
    css["h2"] = "color:var(--heading);border-bottom:1px solid var(--heading);padding:0.2em 0.1em;";
    css["h2 a"] = "color:var(--heading);";
    css["h3"] = "color:var(--heading);border-bottom:1px solid var(--heading);padding:0.1em 0.1em;";
    css["h3 a"] = "color:var(--heading);";
    css["h4,h5,h6"] = "padding:0.1em 0.1em;";
    css["h4 a,h5 a,h6 a"] = "color:var(--heading);";
    css["h1,h2,h3,h4,h5,h6"] = "font-weight:bolder;line-height:1.2em;";
    css["h4"] = "border-bottom:1px solid var(--heading)";
    css["p"] = "margin:0.5em 0.1em;"
    css["hr"] = "background:var(--color);height:1px;border:0;"
    css["a.normal, a.toc, a.footnote, a.footnote-back"] = "color:var(--alt-color);";
    #css["a.normal:visited"] = "color:var(--heading);";
    #css["a.normal:active"] = "color:var(--heading);";
    css["a.normal:hover, a.toc:hover"] = "color:var(--alt-color);";
    css["a.top"] = "font-size:x-small;text-decoration:initial;float:right;";
    css["a.header svg"] = "opacity:0;";
    css["a.header:hover svg"] = "opacity:1;";
    css["a.header"] = "text-decoration: none;";
    css["a.dark-toggle"] = "float:right; cursor: pointer; font-size: small; padding: 0.3em 0.5em 0.5em 0.5em; font-family: monospace; border-radius: 3px;";
    css["a.dark-toggle:hover"] = "background:var(--alt-background);";
    css[".toc-button"] = "color:var(--alt-color);cursor:pointer;font-size:small;padding: 0.3em 0.5em 0.5em 0.5em;font-family:monospace;border-radius:3px;";
    css["a.toc-button:hover"] = "background:var(--alt-background);";
    css["a.footnote"] = "font-size:smaller;text-decoration:initial;";
    css["a.footnote-back"] = "text-decoration:initial;font-size:x-small;font-style:italic;";
    css["strong,b"] = "color:var(--color)";
    css["code"] = "color:var(--alt-color);font-weight:bold;";
    css["blockquote"] = "margin-left:1em;color:var(--alt-color);border-left:0.2em solid var(--alt-color);padding:0.25em 0.5em;overflow-x:auto;";
    css["pre:has(code.nohighlight)"] = "color:var(--alt-color);background:var(--alt-background);line-height:22px;margin:0.25em 0.5em;padding:1em;overflow-x:auto;";
    css["pre code.hljs"] = "margin:0.25em 0.5em -1em;"
    css["table.dawk-ex"] = "border-collapse:collapse;margin:0.5em;";
    css["th.dawk-ex,td.dawk-ex"] = "padding:0.5em 0.75em;border:1px solid var(--heading);";
    css["th.dawk-ex"] = "color:var(--heading);border:1px solid var(--heading);border-bottom:2px solid var(--heading);";
    css["tr.dawk-ex:nth-child(odd)"] = "background-color:var(--alt-background);";
    css["table.da"] = "border-collapse:collapse;margin:0.5em;";
    css["table.da th,td"] = "padding:0.5em 0.75em;border:1px solid var(--heading);";
    css["table.da th"] = "color:var(--heading);border:1px solid var(--heading);border-bottom:2px solid var(--heading);";
    css["table.da tr:nth-child(odd)"] = "background-color:var(--alt-background);";
    css["div.dawk-ex"] = "padding:0.5em;";
    css["caption.dawk-ex"] = "padding:0.5em;font-style:italic;";
    css["dl"] = "margin:0.5em;";
    css["dt"] = "font-weight:bold;";
    css["dd"] = "padding:0.2em;";
    css["mark.dawk-ex"] = "color:var(--alt-background);background-color:var(--heading);";
    css["del.dawk-ex,s.dawk-ex"] = "color:var(--heading);";
    css["div#table-of-contents"] = "padding:0;font-size:smaller;";
    css["abbr"] = "cursor:help;";
    css["ol.footnotes"] = "font-size:small;color:var(--alt-color)";
    css[".fade"] = "color:var(--alt-background);";
    css[".highlight"] = "color:var(--alt-color);background-color:var(--alt-background);";
    css["summary"] = "cursor:pointer;";
    css["ul.toc"] = "list-style-type:none;";
    css["details.credits"] = "opacity: 0.7;font-size: xx-small; border-top: 1px solid var(--heading);margin-top: 4em;";
    css["details.credits summary"] = "font-style: italic;";

    css["p.alert-head"] = "font-weight: bolder;";
    css["p.alert-head svg"] = "margin-right: 0.5em;";
    css["blockquote.alert"] = "background: var(--alt-background);";
    css["blockquote.alert-note"] = "border-left:0.3em solid " icon_color("note") ";";
    css["blockquote.alert-note .alert-head"] = "color: " icon_color("note") ";";
    css["blockquote.alert-tip"] = "border-left:0.3em solid " icon_color("tip") ";";
    css["blockquote.alert-tip .alert-head"] = "color: " icon_color("tip") ";";
    css["blockquote.alert-important"] = "border-left:0.3em solid " icon_color("important") ";";
    css["blockquote.alert-important .alert-head"] = "color: " icon_color("important") ";";
    css["blockquote.alert-warning"] = "border-left:0.3em solid " icon_color("warning") ";";
    css["blockquote.alert-warning .alert-head"] = "color: " icon_color("warning") ";";
    css["blockquote.alert-caution"] = "border-left:0.3em solid " icon_color("caution") ";";
    css["blockquote.alert-caution .alert-head"] = "color: " icon_color("caution") ";";

    css["div.code-block .code-button"] = "border:2px solid rgb(from var(--alt-color) r g b / 20%);background: var(--background);" \
                                            "width:16px;height:16px;" \
                                            "cursor:pointer;padding:4px;border-radius:2px;opacity:0;" \
                                            "transition-property: opacity; transition-duration: .25s;";
    css["div.code-block:hover .code-button"] = "opacity:1 !important;";
    css["div.code-block"] = "position: sticky;";
    css["div.code-toolbar"] = "display: flex;justify-content: flex-end;width: 100%;position: absolute;right: 12px; top: 4px;";
    css[".hidden"] = "opacity:0; transition-property: opacity; transition-duration: .5s;";
    css["span.code-message"] = "font-size: smaller; padding: 0.2em 0.5em;";

    # This is a trick to prevent page-breaks immediately after headers
    # https://stackoverflow.com/a/53742871/115589
    css["blockquote,code,pre,table"] = "break-inside: avoid;break-before: auto;"
    css["section"] = "break-inside: avoid;break-before: auto;"
    css["h1,h2,h3,h4"] = "break-inside: avoid;";
    css["h1::after,h2::after,h3::after,h4::after"] = "content: \"\";display: block;height: 200px;margin-bottom: -200px;";

    if(NumberHeadings)  {
        if(NumberH1s) {
            css["body"] = css["body"] "counter-reset: h1 toc1;";
            css["h1"] = css["h1"] "counter-reset: h2 h3 h4;";
            css["h2"] = css["h2"] "counter-reset: h3 h4;";
            css["h3"] = css["h3"] "counter-reset: h4;";
            css["h1::before"] = "content: counter(h1) \" \"; counter-increment: h1; margin-right: 10px;";
            css["h2::before"] = "content: counter(h1) \".\"counter(h2) \" \";counter-increment: h2; margin-right: 10px;";
            css["h3::before"] = "content: counter(h1) \".\"counter(h2) \".\"counter(h3) \" \";counter-increment: h3; margin-right: 10px;";
            css["h4::before"] = "content: counter(h1) \".\"counter(h2) \".\"counter(h3)\".\"counter(h4) \" \";counter-increment: h4; margin-right: 10px;";

            css["li.toc-1"] = "counter-reset: toc2 toc3 toc4;";
            css["li.toc-2"] = "counter-reset: toc3 toc4;";
            css["li.toc-3"] = "counter-reset: toc4;";
            css["a.toc-1::before"] = "content: counter(h1) \"  \";counter-increment: toc1;";
            css["a.toc-2::before"] = "content: counter(h1) \".\" counter(toc2) \"  \";counter-increment: toc2;";
            css["a.toc-3::before"] = "content: counter(h1) \".\" counter(toc2) \".\" counter(toc3) \"  \";counter-increment: toc3;";
            css["a.toc-4::before"] = "content: counter(h1) \".\" counter(toc2) \".\" counter(toc3) \".\" counter(toc4) \"  \";counter-increment: toc4;";

        } else {
            css["h1"] = css["h1"] "counter-reset: h2 h3 h4;";
            css["h2"] = css["h2"] "counter-reset: h3 h4;";
            css["h3"] = css["h3"] "counter-reset: h4;";
            css["h2::before"] = "content: counter(h2) \" \";counter-increment: h2; margin-right: 10px;";
            css["h3::before"] = "content: counter(h2) \".\"counter(h3) \" \";counter-increment: h3; margin-right: 10px;";
            css["h4::before"] = "content: counter(h2) \".\"counter(h3)\".\"counter(h4) \" \";counter-increment: h4; margin-right: 10px;";

            css["li.toc-1"] = "counter-reset: toc2 toc3 toc4;";
            css["li.toc-2"] = "counter-reset: toc3 toc4;";
            css["li.toc-3"] = "counter-reset: toc4;";
            css["a.toc-2::before"] = "content: counter(toc2) \"  \";counter-increment: toc2;";
            css["a.toc-3::before"] = "content: counter(toc2) \".\" counter(toc3) \"  \";counter-increment: toc3;";
            css["a.toc-4::before"] = "content: counter(toc2) \".\" counter(toc3) \".\" counter(toc4) \"  \";counter-increment: toc4;";
        }
    }

    # Font Family:
    ff = "sans-serif";
    fs = "11pt";

    for(i = 0; i<=255; i++)_hex[sprintf("%02X",i)]=i;

    # Light theme colors:
    lt = "--color: #263053; --alt-color: #383A42; --heading: #2A437E; --background: #FDFDFD; --alt-background: #FAFAFA;";
    # Dark theme colors:
    dt = "--color: #E9ECFF; --alt-color: #ABB2BF; --heading: #6C89E8; --background: #13192B; --alt-background: #282C34;";

    # Print theme: Same as light theme...
    pt = lt;
    # ...but make sure the background is white
    sub(/--background:[[:space:]]*#?[[:alnum:]]+/, "--background: white", pt);

    ss = "@media screen {\n" \
        "  body { " lt " }\n" \
        "  body.dark-theme { " dt " }\n" \
        "  @media (prefers-color-scheme: dark) {\n" \
        "    body { " dt " }\n" \
        "    body.light-theme { " lt " }\n" \
        "  }\n" \
        "}\n" \
        "@media print {\n" \
        "  body  { " pt " }\n" \
        "  pre code.highlight.hljs {overflow-x:hidden;}" \
        "}";

    for(k in css)
        ss = ss "\n" k "{" css[k] "}";
    gsub(/%maxwidth%/,MaxWidth,ss);
    gsub(/%font-family%/,ff,ss);
    gsub(/%font-size%/,fs,ss);
    gsub(/%hr%/,hr,ss);

    return ss;
}
function icon_color(which) {
    if(which == "note") return "#3d88f1";
    if(which == "tip") return "#029802";
    if(which == "important") return "#a30fa3";
    if(which == "warning") return "#ffb328";
    if(which == "caution") return "#fa1c1c";
    return "black";
}
function svg(which, color, size,        path, body) {
    # TODO: Get better at Inkscape
    if(which == "moon")
        path = "M 10.04 0.26 A 11.64 11.64 0 0 1 10.79 4.36 A 11.64 11.63625 0 0 1 4.01 14.94 A 8 8 0 0 0 8 16 A 8 8 0 0 0 16 8 A 8 8 0 0 0 10.04 0.26 z";
    else if(which == "link")
        path = "m 3.34,4.63 1.31,2.66 0,0 0.61,1.24 0.01,0 1.23,2.5 L 9.52,9.58 8.91,8.34 7.17,9.18 6.82,8.47 6.55,7.92 5.94,6.68 5.59,5.96 5.24,5.26 11.74,2.13 13.67,6.05 11.25,7.21 11.86,8.45 15.53,6.69 12.39,0.29 Z M 0.47,9.31 3.61,15.71 12.63,11.37 11.67,9.43 11.32,8.71 10.71,7.47 10.43,6.92 9.48,4.97 6.48,6.42 7.09,7.66 8.84,6.82 9.19,7.52 9.46,8.08 10.07,9.32 10.42,10.03 10.76,10.73 4.26,13.87 2.33,9.95 4.75,8.79 4.14,7.55 Z";
    else if(which == "note")
        path = "M 8 0 A 8 8 0 0 0 0 8 A 8 8 0 0 0 8 16 A 8 8 0 0 0 16 8 A 8 8 0 0 0 8 0 z M 8 1.52 C 11.60 1.52 14.48 4.40 14.48 8 C 14.48 11.60 11.60 14.48 8 14.48 C 4.40 14.48 1.52 11.60 1.52 8 C 1.52 4.40 4.40 1.52 8 1.52 z M 7.01 3.22 L 7.01 4.87 L 8.99 4.87 L 8.99 3.22 L 7.01 3.22 z M 6.28 5.51 L 6.28 7.15 L 7.01 7.15 L 7.01 11.45 L 6.28 11.45 L 6.28 13.09 L 7.01 13.09 L 8.99 13.09 L 9.70 13.09 L 9.70 11.45 L 8.99 11.45 L 8.99 5.51 L 8.97 5.51 L 6.28 5.51 z";
    else if(which == "tip")
        path = "M 8 0.06 C 4.8 0.06 2.29 2.12 2.29 6.04 C 2.29 8 4.02 8.96 5.07 10.24 C 5.34 10.58 5.56 11.13 5.77 11.75 L 6.98 11.75 C 6.71 10.93 6.38 10.04 5.96 9.52 C 5.51 8.98 4.84 8.37 4.45 7.97 C 3.79 7.3 3.43 6.81 3.43 6.04 C 3.43 4.32 3.95 3.17 4.74 2.4 C 5.53 1.63 6.64 1.21 8 1.21 C 9.36 1.21 10.53 1.63 11.36 2.41 C 12.19 3.19 12.73 4.33 12.73 6.04 C 12.73 6.75 12.33 7.25 11.59 7.94 C 11.16 8.34 10.43 8.95 9.96 9.52 C 9.7 9.85 9.49 10.27 9.34 10.63 C 9.22 10.95 9.09 11.34 8.96 11.75 L 10.16 11.75 C 10.36 11.13 10.58 10.58 10.85 10.24 C 11.9 8.96 13.88 8 13.88 6.04 C 13.88 2.12 11.2 0.06 8 0.06 z M 5.96 12.35 L 5.96 13.55 L 10.13 13.55 L 10.13 12.35 L 5.96 12.35 z M 6.56 14.21 L 6.56 15.41 L 9.54 15.41 L 9.54 14.21 L 6.56 14.21 z";
    else if(which == "important")
        path = "M 0 0 L 0 12.42 L 8.16 12.42 L 8.14 16 L 13.17 12.42 L 16 12.42 L 16 0 L 0 0 z M 1.52 1.52 L 14.48 1.52 L 14.48 10.9 L 12.69 10.9 L 9.68 13.04 L 9.7 10.9 L 1.52 10.9 L 1.52 1.52 z M 6.6 2.64 L 6.6 7.13 L 8.87 7.13 L 8.87 2.64 L 6.6 2.64 z M 6.6 8.11 L 6.6 10.01 L 8.87 10.01 L 8.87 8.11 L 6.6 8.11 z";
    else if(which == "warning")
        path = "M 8 0 L 0 15.969 L 15.97 16 L 8 -0.02 z M 8 3.26 L 13.53 14.36 L 2.43 14.34 L 8.01 3.26 z M 7.23 6.13 L 7.23 10.6 L 8.77 10.6 L 8.77 6.13 L 7.23 6.13 z M 7.23 11.69 L 7.23 13.38 L 8.77 13.38 L 8.77 11.69 L 7.23 11.69 z";
    else if(which == "caution")
        path = "M 4.7 0 L 0.01 4.68 L 0 11.3 L 4.68 16 L 11.3 16 L 16 11.32 L 16 4.7 L 11.32 0.01 L 4.7 0 z M 5.33 1.52 L 10.7 1.53 L 14.48 5.33 L 14.47 10.7 L 10.67 14.48 L 5.31 14.47 L 1.52 10.67 L 1.53 5.31 L 5.33 1.52 z M 6.82 2.75 L 6.82 9.58 L 9.18 9.58 L 9.18 2.75 L 6.82 2.75 z M 6.82 10.55 L 6.82 13.14 L 9.18 13.14 L 9.18 10.55 L 6.82 10.55 z";
    else if(which == "copy")
        path = "M 5.8 0.9 L 5.8 3.6 L 7 3.6 L 7 2 L 14 2 L 14 10 L 11.6 10 L 11.6 11 L 15.1 11 L 15.1 0.9 L 5.8 0.9 z M 1.2 4.8 L 1.2 14.9 L 10.5 14.9 L 10.5 4.8 L 1.2 4.8 z M 2.3 5.9 L 9.3 5.9 L 9.3 13.7 L 2.3 13.7 L 2.3 5.9 z";
    else
        path = "";

    if(!UsedSymbols[which]) {
        UsedSymbols[which] = 1;
        body = "<symbol id=\"icon-" which "\"><path d=\"" path "\"/></symbol><use href=\"#icon-" which "\"/>";
    } else {
        body = "<use fill=\"" color "\" href=\"#icon-" which "\"/>";
    }

    if(!color) color = "var(--color)";
    if(!size) size = "16";

    return "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 16 16\" width=\"" size "\" height=\"" size "\" fill=\"" color "\">" body "</svg>"
}
