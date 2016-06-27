Name:       perl-Term-Highlight
Version:    1.8.8
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

