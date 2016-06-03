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

