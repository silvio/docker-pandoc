# this dockerfile is an import from https://registry.hub.docker.com/u/jagregory/pandoc/dockerfile/
# I have done some changes

FROM debian:jessie

#MAINTAINER James Gregory <james@jagregory.com>
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>

RUN ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# install haskell
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get upgrade -y

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y haskell-platform texlive-latex-base \
			  texlive-xetex latex-xcolor texlive-math-extra \
			  texlive-latex-extra texlive-fonts-extra \
			  texlive-bibtex-extra texlive-lang-all \
			  curl wget git fontconfig make \
			  inotify-tools \
    && apt-get clean -y

# install pandoc
RUN cabal update && cabal install pandoc

RUN mkdir -p /source
WORKDIR /source

VOLUME ["/source"]
ENTRYPOINT ["/start.sh"]
CMD ["--help"]

# Add startscript
ADD adds/start.sh /start.sh
ADD readme.md /readme.docker.md
RUN chmod 777 /start.sh

RUN export DEBIAN_FRONTEND=noninteractive \
    && git clone https://github.com/jgm/pandocfilters.git /pandocfilters \
    && cd /pandocfilters \
    && python setup.py install \
    && cp examples/*.py /usr/bin \
    && ls examples/*.py > /installed-pandocfilters.txt \
    && rm -rf /pandocfilters \
    && apt-get install -y abcm2ps python-pygraphviz graphviz imagemagick
