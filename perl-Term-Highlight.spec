Name:       perl-Term-Highlight
Version:    2.1.1
Release:    1%{?dist}
License:    GPL+ or Artistic
Group:      Development/Libraries
Summary:    Simple way to highlight perl-compatible regexp patterns on terminals
Source:     http://search.cpan.org/CPAN/authors/id/R/RA/RADKOV/Term-Highlight-%{version}.tar.gz
Url:        http://github.com/lyokha/hl
BuildArch:  noarch
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:   perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

BuildRequires: perl(ExtUtils::MakeMaker)


%description
Term::Highlight is a Perl module which can help to highlight
virtually unlimited number of specified regexp patterns with
different colors using ANSI terminal color escape sequences.
Term::Highlight supports 256 and 8 colors capable terminals.
The package ships with full-featured script 'hl' which can also
be used as a grep-like engine. You can use hl to just learn
Perl regular expressions!

%prep
%setup -q -n Term-Highlight-%{version}

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor OPTIMIZE="%{optflags}"
make %{?_smp_mflags}

%install
rm -rf %{buildroot}

make pure_install PERL_INSTALL_ROOT=%{buildroot}
find %{buildroot} -type f -name .packlist -exec rm -f {} ';'
find %{buildroot} -type f -name '*.bs' -a -size 0 -exec rm -f {} ';'
find %{buildroot} -depth -type d -exec rmdir {} 2>/dev/null ';'

%{_fixperms} %{buildroot}/*

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc Changes README
%{perl_vendorlib}/*
%{_bindir}/hl
%{_mandir}/man3/*.3*
%{_mandir}/man1/*.1*

%changelog
* Fri Jan 17 2020 Alexey Radkov <alexey.radkov@gmail.com> 2.1.1-1
- hl version 2.1.1, corrected and faster line endings split.

* Wed Jan 15 2020 Alexey Radkov <alexey.radkov@gmail.com> 2.1.0-1
- hl version 2.1.0, no longer grep hidden files and descend into hidden
  directories by default. A new option -a was added to do so.

* Tue Nov 13 2018 Alexey Radkov <alexey.radkov@gmail.com> 2.0.4-1
- hl version 2.0.4, explicitly licensed by the Perl 5 license.

* Fri May 25 2018 Alexey Radkov <alexey.radkov@gmail.com> 2.0.3-1
- hl version 2.0.3, added new global option -f to build the file list
  from the trailing arguments automatically when option - is not specified,
  fixed handling of option 0.

* Sun Apr 01 2018 Alexey Radkov <alexey.radkov@gmail.com> 2.0.2-1
- hl version 2.0.2, better treatment of the trailing highlight options
  not followed by a pattern

* Fri Mar 30 2018 Alexey Radkov <alexey.radkov@gmail.com> 2.0.1-1
- hl version 2.0.1, do not pass newlines from hl to the module part

* Thu Mar 29 2018 Alexey Radkov <alexey.radkov@gmail.com> 2.0.0-1
- hl version 2.0.0, Highlight.pm version 2.0.0,
  fixed color tags offsets at ends of lines
  with support for "\r\n" line endings

* Sat Jul 23 2016 Alexey Radkov <alexey.radkov@gmail.com> 1.9.4-1
- hl version 1.9.4, Highlight.pm version 1.8

* Fri Jul 22 2016 Alexey Radkov <alexey.radkov@gmail.com> 1.9.3-1
- hl version 1.9.3, expensive Process() calls optimized

* Thu Jul 21 2016 Alexey Radkov <alexey.radkov@gmail.com> 1.9.2-1
- hl version 1.9.2, Highlight.pm version 1.7

* Thu Jul 21 2016 Alexey Radkov <alexey.radkov@gmail.com> 1.9.1-1
- hl version 1.9.1, Highlight.pm version 1.6

* Thu Jul 14 2016 Alexey Radkov <alexey.radkov@gmail.com> 1.9.0-1
- hl version 1.9.0, unicode symbols in input patterns, granular snippet files

* Tue Jun 28 2016 Alexey Radkov <alexey.radkov@gmail.com> 1.8.9-1
- hl version 1.8.9, fixes in context lines processing

* Mon Jun 27 2016 Alexey Radkov <alexey.radkov@gmail.com> 1.8.8-1
- hl version 1.8.8, added option -c to print context lines around matches

* Sun Jun 26 2016 Alexey Radkov <alexey.radkov@gmail.com> 1.8.7-1
- hl version 1.8.7, Highlight.pm version 1.5

* Sun Jun 05 2016 Alexey Radkov <alexey.radkov@gmail.com> 1.8.6-1
- hl version 1.8.6, minor bug fixes and docs updates

* Wed Jun 01 2016 Alexey Radkov <alexey.radkov@gmail.com> 1.8.5-1
- hl version 1.8.5, much faster start time when recursive grep is not needed

* Tue May 31 2016 Alexey Radkov <alexey.radkov@gmail.com> 1.8.4-1
- hl version 1.8.4, Highlight.pm version 1.4

* Sun Oct 25 2015 Alexey Radkov <alexey.radkov@gmail.com> 1.8-1
- hl version 1.8, Highlight.pm version 1.3

* Fri Sep 17 2010 Alexey Radkov <alexey.radkov@gmail.com> 1.7-1
- version 1.7, hl script can now load snippets from file .hlrc in HOME directory

* Tue Aug 17 2010 Alexey Radkov <alexey.radkov@gmail.com> 1.6-1
- version 1.6, hl script bugfix

* Thu Dec 25 2008 Alexey Radkov <alexey.radkov@gmail.com> 1.5-1
- initial RPM packaging

