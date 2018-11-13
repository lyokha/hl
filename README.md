hl
==

[![CPAN](https://img.shields.io/cpan/v/Term-Highlight.svg)](https://metacpan.org/release/Term-Highlight)
[![License](https://img.shields.io/cpan/l/Term-Highlight.svg)](https://dev.perl.org/licenses/)

Universal PCRE-based terminal highlighter which is compatible with older 8-color
and modern 256-color terminals. It consists of a Perl module *Term::Highlight*
that is capable of inserting *ANSI terminal color escape sequences* at positions
calculated for specified regular expressions, and a Perl script *hl* that uses
the module.

Table of contents
-----------------

- [Motivational example](#motivational-example)
- [Installation](#installation)
- [Highlighting rules aka snippets](#highlighting-rules-aka-snippets)
- [Integration with shell](#integration-with-shell)
- [Grep-like functionality](#grep-like-functionality)
- [man *hl*](#man-hl)
- [man *Term::Highlight*](#man-termhighlight)
- [See also](#see-also)

Motivational example
--------------------

<p align="center">
  <img src="../images/images/POE_RAVEN.png?raw=true" alt="poe_raven"/>
</p>

In this example output of *``cat RAVEN_POE``* with the famous Poe's masterpiece
verse is piped to *hl*. All *words* that start with capital letters
(*``\b[A-Z]\w*``*) are highlighted with *foreground* color that corresponds to
ANSI code *37* (*``-37``*) in *bold* typeface (*``-b``*), all *single-character*
words (*``\b.\b``*, *a* and *I* here) are highlighted with foreground color *68*
in *normal* typeface (*``-rb``* stands for *reset bold*), all *non-word*
characters (*``\W``*) are highlighted with foreground color *119*, all words
that end with *ing* and *ed* (*``ing\b``* and *``ed\b``*) are highlighted with
foreground color *41* and *background* color *23* (*``-23.1``*), all characters
at column 31 (*``(?<=^.{30}).``*) are highlighted with the previously defined
foreground color (*41*) and background color *124*.

In the next command an *environment variable* *HL_INITSTRING* is defined. It
contains *default* *highlight options* for *hl*. In this example the variable is
equal to *``-46``* that defines default foreground color for patterns. In the
next command *hl* is not fed with specific patterns, therefore all text is
highlighted with color *46*. Finally, the command *``cat RAVEN_POE | hl 'ing\b'
'ed\b'``* highlights *gerunds* and *participles* with default color *46* in the
Poe's masterpiece.

Installation
------------

In the following listings prompt ``$`` belongs to a regular user while prompt
``#`` &mdash; to a superuser.

```ShellSession
$ perl Makefile.PL
$ make
# make install
```

or simply

```ShellSession
# cpan install Term::Highlight
```

Highlighting rules aka snippets
----------------------------

Typing long highlight options like in the commands from the above example in a
terminal is boring and error-prone. *Hl* allows reading highlight options from
file *.hlrc* located in the home directory. Examples of such *highlighting
rules* or *snippets* can be found in [conf/.hlrc](conf/.hlrc).

Integration with shell
----------------------

Ubiquitous UNIX and Linux programs like *make*, *diff* and *ack* can make use of
rich highlighting features of *hl* via their own configuration settings or
dedicated shell functions. Below are shown examples of such integration that use
snippets from [conf/.hlrc](conf/.hlrc), special settings for *ack* from
[conf/.ackrc](conf/.ackrc), and various shell functions from
[conf/.hl_functions](conf/.hl_functions). To automatically enable highlighting
in shell functions after login to the system, add line

```sh
. $HOME/.hl_functions
```

into *&#36;HOME/.bashrc*.

- grep-like utilities for developers *ack* and *cgrep*

<p align="center">
  <img src="../images/images/ACK_CGREP.png?raw=true" alt="ack_cgrep"/>
</p>

- *git diff*

<p align="center">
  <img src="../images/images/DIFF.png?raw=true" alt="diff"/>
</p>

- network sniffer *ngrep*

<p align="center">
  <img src="../images/images/NGREP.png?raw=true" alt="ngrep"/>
</p>

Grep-like functionality
-----------------------

*hl* can be used as an easy *grep-like* utility. Below is an example.

<p align="center">
  <img src="../images/images/HLGREP.png?raw=true" alt="hlgrep"/>
</p>

(*hlgrep* is a shell function from *.hl_functions*)

man hl
------

#### SYNOPSIS

```
hl [global-options] [[--] highlight-options [patterns] ...] [- file1 [file2] ...]
```

#### DESCRIPTION

hl reads text from list of files or standard input and prints it on terminal
with specified patterns highlighted using ANSI color escape sequences.
Patterns are intrinsically Perl-compatible regular expressions.

Global options are processed internally by hl whereas highlight options
are passed into Term::Highlight module, therefore they should not mix.
The first occurrence of an option which has not been recognized as global is
regarded as beginning of highlight options.
Highlight options can be explicitly separated from global options with option
`--` (must not be confused with option `-` that separates list of files from
highlight options).

*Global options:*

- **-s &lt;snippet&gt;**
      loads a snippet with specified name from file *\~/.hlrc* or
      *\~/.hlrc_&lt;snippet&gt;*. The white space between `-s` and the name of
      the snippet may be omitted. For example `-sW` loads snippet with name `W`.
      Multiple options `-s` with different snippet names are allowed.

- **-g (-grep)**
      prints only lines that match specified patterns.

- **-r**  greps recursively, implies `-g`. If the file list is empty then grep
      starts in the current directory.

- **-f (-flist)**
      builds the file list from the trailing arguments automatically when option
      `-` is not specified.

- **-l**  prints the list of files where matches were found, implies `-g`.

- **-c &lt;pre[.post]&gt;**
      where *pre* and *post* are numbers. Prints context lines around matches.
      If *post* is not set then it is supposed to be equal to *pre*,
      implies `-g`.

- **-n**  prints line numbers.

- **-u (-utf8)**
      enables matching of Unicode characters from UTF−8 encoded input. For
      instance matching against `\x{239C}` or `функци[яи]` will not work without
      this option.

- **-b (-bin)**
      enables processing of binary files (not enabled by default).

- **-t (-term)**
      forces using ANSI color escape sequences even when output is not a
      terminal, this may be useful when output is piped to `less -r` or alike.

- **-d (-debug)**
      turns on debug support (colors are printed out as symbolic sequences).

- **-h (-help)**
      prints usage and exits.

*Highligh options:*

- **-x\[xx\]\[.b\]**
      highlights following patterns with color defined by number *x\[xx\]*.
      *x\[xx\]* is color id corresponding to an ANSI color escape sequence
      number and thus should range within *\[0 .. 255\]*. *b* must be 0 or 1:
      `.0` applies the color id to foreground, `.1` − to background. `.0`
      is default choice and may be omitted. If your terminal does not support
      256 colors then valid color ids are *\[0 .. 15\]*. *Note*: if your
      terminal is 256 colors capable then better use *\[16 .. 255\]* colors!
      To see for how many colors your terminal has support use command **tput
      colors**.

- **-i**  sets ignorecase search.

- **-ni** unsets ignorecase search.

- **-b**  sets bold font.

- **-rfg**
      resets foreground color to default value.

- **-rb** resets bold font to normal.

- **-rbg**
      resets background color to default value.

- **-r**  resets both background color and bold font.

- **-ra** resets all settings to default values.

Highlight options apply to following them regexp patterns or to the
whole text if trailing highlight options are not followed by patterns.

It is possible to define common highlight options on session level. hl
supports environment variable *HL_INITSTRING* which value will be
prepended to any highlight options given in command line.

*Highlight options separators:*

- **--**  explicitly separates global and highlight options.

- **-**   separates global and highlight options from list of files to process.
      As soon as hl may read from standard input or use option `-f`, using a
      list of files to process is not obligatory.

#### ENVIRONMENT VARIABLES

**HL\_INITSTRING**

defines common highlight options which will be prepended to any
highlight options given in command line. For example setting
`HL_INITSTRING='-21 -i'` will make hl highlight patterns with
color id *21* and ignore cases without explicit definition of
highlight options in command line. *Note*: *HL_INITSTRING* must not
contain global options!

**HL\_LOCATION**

defines highlight options for file names and line numbers when they
are printed. For example setting `HL_LOCATION='-224 (?<=:)\d+$ -248'` will make
hl print file names with color id *248* and line numbers with color id *224*.

**HL\_CTXDELIM**

defines highlight options for context chunks delimiters (double dashes) when
they are printed. For example setting `HL_CTXDELIM=-248` will make hl print
context chunks delimiters with color id *248*.

#### EXAMPLES

    ls | hl -b -46.1 -21 '\bw.*?\b'

reads output of command **ls** and highlights words that start with *w* in
color id *21* using color id *46* for background and bold font.

#### FILES

**\~/.hlrc** and **\~/.hlrc_&lt;snippet-name&gt;**

currently these files may contain only snippets that can be loaded with
option `-s`. The format of the snippet line is

    snippet name highlight_options

where *snippet* is a keyword, *name* is the name of the snippet and
*highlight\_options* contains highlight options possibly preceded by the
global option `-u`. Here is an example of a snippet to highlight words that
start with a capital letter.

    snippet W -130 (?:^|[\s])[A-Z]\S+

Lines that do not match the snippet line pattern are ignored. Arguments
of *highlight\_options* are naturally split by white spaces. If you want to
use white spaces inside patterns then put single quotes around the patterns.
Single quote by itself must be escaped by a backslash. Too long lines
can be split into multiple lines using backslashes.

Files with names containing specific snippet names are loaded before *\~/.hlrc*:
they are supposed to declare a single snippet (perhaps with a few auxiliary
snippets) to help *hl* start faster.

man Term::Highlight
-------------------

#### SYNOPSIS

```
use Term::Highlight;
$obj = Term::Highlight->new( tagtype => $TAGTYPE );
$obj->LoadPatterns( \@ptns );
$obj->LoadArgs( \@args );
$obj->GetPatterns( );
$obj->ClearPatterns( );
$obj->Process( \$string );
```

Currently `term` and `term-debug` tagtypes are supported. If tagtype
is `term` then boundaries of found patterns will be enclosed in
ANSI terminal color escape sequence tags, if tagtype is `term-debug` then
they will be marked by special symbolic sequences.

#### DESCRIPTION

Term::Highlight is a Perl module aimed to support highlighting of regexp
patterns on color terminals. It supports 256 color terminals as well as older
8 color terminals.

#### EXPORTS

**LoadPatterns**

expects a reference to an array of references to arrays of type
``[ $pattern, $fg, $bold, $bg ]``. Loads patterns to be processed.

**LoadArgs**

expects an array of references to strings. Loads patterns to be processed.
This is just a convenient version of `LoadPatterns`. Example of array
to be loaded: ``[ "-46", "-25.1", "-i", "\bw.*?\b", "-100" ]``.

**GetPatterns**

returns a reference to the loaded patterns.

**ClearPatterns**

clears the loaded patterns.

**Process**

expects a reference to a string. Makes substitution of color tags inside the
string. Returns count of found matches.

See also
--------

There are some articles about *hl* in my blog all written in Russian:

1. [*Использование пользовательской подсветки команд в терминале (на примере
make)*](http://lin-techdet.blogspot.com/2011/09/make.html).
2. [*Статистика, diff,
подсветка*](http://lin-techdet.blogspot.com/2012/11/diff.html).

*Hl* at *cpan.org*:
[*hl*](http://metacpan.org/pod/distribution/Term-Highlight/hl),
[*Term::Highlight*](http://metacpan.org/pod/Term::Highlight).

