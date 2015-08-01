---
header-includes:
    - \usepackage[a4paper]{geometry}
---

# Introduction

[Pandoc] in a container and NO Haskel on your host!

Please read the [pandoc user guide] and for specially for markdown the
[markdown spec].

# Installation

Retrieve the docker image via `docker pull` and create an alias in your
`.${SHELL}rc`.

```
% docker pull silviof/docker-pandoc
  [...]
% alias pandoc='docker run -ti -v ${PWD}:/source --rm silviof/docker-pandoc'
```

# Environmentvariables

PUID

: User ID of generated file

PGID

: Group ID of generated files

Use this via `-e` option for docker eg.: `-e PUID=${UID} -e PGID=${GID}`.

# Modes

You can use this Dockerimage as an alias within your shell or as a inotify
based server.

## Server mode

If you write a file which you need to convert to other formats you can listen
on your documents, the pandock-"server" generate your needed format every time
you save your source file.

```
SYNOPSIS:
       pandoc server [PANOPTION] -- <FORMAT> <FILE>...

DESCRIPTION:
       inotify based listining on FILEs and convert at save event of this
       files to "FILE.FORMAT".
       To divide

       PANOPTION
              optional, normal pandoc options. see "pandoc --help"

       FORMAT
              convert format, see supported formats with "pandoc -v"

       FILE
              FILEs to convert. The FILE argument needs a supported FORMAT too.

EXAMPLES:

       $ ls
       x.md y.md
       $ pandoc server -- pdf x.md y.md
       (1) :: x.md -> x.md.pdf ($?: 0)
       (2) :: y.md -> y.md.pdf ($?: 0)


```

## Alias

Simple use it like any other command.

```
% pandoc -v
pandoc 1.13.2
Compiled with texmath 0.8.0.1, highlighting-kate 0.5.11.1.
Syntax highlighting is supported for the following languages:
    abc, actionscript, ada, agda, apache, asn1, asp, awk, bash, bibtex, boo, c,
[...]
```

<!-- links -->
[pandoc]: http://johnmacfarlane.net/pandoc
[pandoc user guide]: http://johnmacfarlane.net/pandoc/README.html#pandocs-markdown
[markdown spec]: http://spec.commonmark.org/
