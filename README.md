hl
==

Universal PCRE-based terminal highlighter which is compatible with older 8-color
and modern 256-color terminals. It consists of a perl module *Term::Highlight*
that is capable of inserting *ANSI terminal color escape sequences* at positions
calculated for specified regular expressions and a perl script *hl* that uses
the module.

Table of contents
-----------------

- [Motivational example](#motivational-example)
- [Installation](#installation)
- [Highlight rules aka snippets](#highlight-rules-aka-snippets)
- [Integration with shell](#integration-with-shell)
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
(*``\b[A-Z]\w``*) are highlighted with *foreground* color that corresponds to
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

```ShellSession
$ perl Makefile.PL
$ make
$ make test
$ make install
```

Highlight rules aka snippets
----------------------------

Typing long highlight options like in the commands from the above example in a
terminal is boring and error-prone. *Hl* allows reading highlight options from
file *.hlrc* located in the home directory. Examples of such *highlight rules*
or *snippets* can be found in [conf/.hlrc](conf/.hlrc).

Integration with shell
----------------------

Ubiquitous UNIX and Linux programs like *make*, *diff* and *ack* can make use of
rich highlighting features of *hl* via their own configuration settings or
dedicated shell functions. Below are shown examples of such integration that use
snippets from [conf/.hlrc](conf/.hlrc), special settings for *ack* from
[conf/.ackrc](conf/.ackrc), and various shell functions from
[conf/.hl_functions](conf/.hl_functions). To enable highlight shell functions
after login to the system, add line

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

man hl
------

### SYNOPSIS

```
hl [global−options] [[−−] highlight-options [patterns] ...] [− file1 [file2] ...]
```

### DESCRIPTION

hl reads text from list of files or stdin and prints it on the console
with specified patterns highlighted using terminal color escape
sequences. Patterns are intrinsically perl-compatible regular
expressions.

Global options are processed internally by hl whereas highlight options
are passed into Term::Highlight module, therefore they should not mix.
The first occurrence of an option which are not recognized as global is
regarded as the beginning of highlight options. Highlight options can be
explicitly separated from global options with option ’−−’ (must not be
confused with option ’−’ that separates list of files from highlight
options).

*Global options:*

- **−s &lt;snippet&gt;**
      loads a snippet with specified name from \~/.hlrc file. The white space
      between ’−s’ and the name of snippet can be omitted. For example −sW
      will load snippet with name ’W’.

- **−g (−grep)**
      prints only lines which match specified patterns.

- **−r**  greps recursively, implies ’−g’. If file list is empty starts search
      in current directory.

- **−l**  prints the list of files where matches were found, implies ’−g’.

- **−u (−utf8)**
      enables matching of Unicode characters from UTF−8 encoded input. For
      instance matching of ’\\x{239C}’ will not work without this option.

- **−b (−bin)**
      enables processing of binary files (not enabled by default).

- **−t (−term)**
      forces using ANSI color escape sequences even when output is not a
      terminal, this may be useful when output is piped to ’less −r’ or alike.

- **−d (−debug)**
      turns on debug support (colors are printed out as symbolic sequences).

- **−h (−help)**
      prints usage and exits.

*Highligh options:*

- **−x\[xx\]\[.b\]**
      highlights following patterns with color defined by number x\[xx\].
      x\[xx\] is color id corresponding to terminal color escape sequence
      number and should range within \[0..255\]. *b* is 0 or 1, .0 applies the
      color id to foreground, .1 − to background, .0 is default value and may
      be omitted. If your terminal does not support 256 colors valid color ids
      are \[0..15\]. *Note*: if your terminal is 256 colors capable better use
      \[16..255\] colors! To see how many colors your terminal supports use
      **tput colors** command.

- **−i**  sets ignorecase search.

- **−ni** unsets ignorecase search.

- **−b**  sets bold font.

- **−rfg**
      resets foreground color to default value.

- **−rb** resets bold font to normal.

- **−rbg**
      resets background color to default value.

- **−r**  resets both background color and bold font.

- **−ra** resets all settings to default values.

Highlight options apply to following them regexp patterns or to the
whole text if trailing highlight options are not followed by patterns.

It is possible to define common highlight options on session level. hl
supports environment variable **HL\_INITSTRING** which value will be
prepended to any highlight options given in command line.

*Highlight options separators:*

- **−−**  explicitly separates global and highlight options.

- **−**   separates global and highlight options from list of files to process.
      As soon as hl may read from stdin, using a list of files to process is not
      obligatory.

### ENVIRONMENT VARIABLES

**HL\_INITSTRING**

defines common highlight options which will be prepended to any
highlight options given in command line. For example setting
**HL\_INITSTRING** ="−21 −i" will make hl highlight patterns with blue
(color id 21) and ignore case of them without explicit definition of
highlight options in command line. *Note*: **HL\_INITSTRING** must not
contain global options!

### EXAMPLES

    ls | hl −b −46.1 −21 'bw.*?\b'

reads output of **ls** command and highlight words starting with *w*
with bold blue (color id 21) foreground and green (color id 46)
background.

### FILES

**\~/.hlrc**

currently this file may contain only snippets that can be loaded with
’−s’ option. The format of the snippet line is

    snippet name highlight_options

where *snippet* is a keyword, *name* is the name of the snippet and
*highlight\_options* contains highlight options possibly preceded by the
global option ’−u’. Here is an example of snippet which can be used to
highlight words that start with capital letter:

    snippet W −130 (?:^|[\s])[A−Z]\S+

Lines that do not match the snippet line pattern are ignored. Arguments
of highlight\_options are naturally split by whitespaces. If you want to
have whitespaces inside patterns you can use single quotes surrounding
them. Single quote itself must be prepended by backslash. Too long lines
can be split into multiple lines using backslash.

man Term::Highlight
-------------------

### SYNOPSIS

```
use Term::Highlight;
$obj = Term::Highlight->new( tagtype => $TAGTYPE );
$obj->LoadArgs( \@args );
$obj->LoadPatterns( \@ptns );
$obj->ClearPatterns( );
$obj->Process( \$string );
```

Currently `term` and `term−debug` tagtypes are supported. If tagtype
is `term` then boundaries of found patterns will be enclosed in
terminal color escape sequence tags, if tagtype is `term−debug` then
they will be marked by symbolic sequences.

### DESCRIPTION

Term::Highlight is perl module aimed to support highlighting of patterns
on color terminals. It supports 256 color terminals and older 8 color
terminals.

### EXPORTS

**LoadPatterns**

expects reference to array of references to arrays of structure
``[ $pattern, $fg, $bold, $bg ]``. Loads patterns to be processed.

**ClearPatterns**

clears loaded patterns.

**LoadArgs**

expects array of references to strings. Loads patterns to be processed.
This is just a convenient version of `LoadPatterns`. Example of array
to be loaded: ``[ "−46", "−25.1", "−i", "\bw.*?\b", "−100" ]``.

**Process**

expects reference to string. Makes substitution of color tags inside the
string. Returns count of found matches.

See also
--------

There are two articles about *hl* in my blog both written in Russian:

1. [*Использование пользовательской подсветки команд в терминале (на примере
make)*](http://lin-techdet.blogspot.ru/2011/09/make.html).
2. [*Статистика, diff,
подсветка*](http://lin-techdet.blogspot.ru/2012/11/diff.html).

*Hl* at *cpan.org*:
[*hl*](http://metacpan.org/pod/distribution/Term-Highlight/hl),
[*Term::Highlight*](http://metacpan.org/pod/Term::Highlight).

