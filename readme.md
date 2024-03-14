# Introduction

[Pandoc] in a container and NO Haskel on your host!

Please read the [pandoc user guide] and for specially for markdown the
[markdown spec].

# Installation

Retrieve the docker image via `docker pull` and create an alias in your
`.${SHELL}rc` or put a shell script somewhere.

```
% docker pull silviof/docker-pandoc
  [...]
% alias pandoc='docker run -ti --rm -v ${PWD}:/source -u"$(uid -u):$(uid -g)" --rm silviof/docker-pandoc'
```


# Modes

You can use this Dockerimage as an alias within your shell or as a inotify
based server.

## Server mode

If you write a file which you need to convert to other formats you can listen
on your documents, the pandock-"server" generate your needed format every time
you save your source file.

```
SYNOPSIS:
       pandoc server [PANOPTION] -- [SERVEROPTION] <FORMAT> <FILE>...

DESCRIPTION:
       inotify based listining on FILEs and convert at save event of this
       files to "FILE.FORMAT".
       To divide

       PANOPTION
              optional, normal pandoc options. see "pandoc --help"

       SERVEROPTION
              optional, option for the server process. Following options are
              supported:

              --output-folder=<folder>          Set destiny folder for output
                                                files

       FORMAT
              convert format, see supported formats with "pandoc -v"

       FILE
              FILEs to convert. The FILE argument needs a supported FORMAT too.

EXAMPLES:

       $ ls
       x.md y.md
       $ pandoc server -- --output-folder=out pdf x.md y.md
       (   1) :: x.md -> out/x.md.pdf ($?: 0)
       (   2) :: y.md -> out/y.md.pdf ($?: 0)


```

<!-- links -->
[pandoc]: http://johnmacfarlane.net/pandoc
[pandoc user guide]: http://johnmacfarlane.net/pandoc/README.html#pandocs-markdown
[markdown spec]: http://spec.commonmark.org/
