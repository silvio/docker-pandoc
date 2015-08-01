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
    && apt-get install -y \
              abcm2ps \
              curl \
              fontconfig \
              git \
              graphviz \
              imagemagick \
              inotify-tools \
              latex-xcolor \
              make \
              python-pygraphviz \
              texlive-bibtex-extra \
              texlive-fonts-extra \
              texlive-lang-all \
              texlive-latex-base \
              texlive-latex-extra \
              texlive-math-extra \
              texlive-xetex \
              wget \
    && apt-get clean -y

ADD https://github.com/jgm/pandoc/releases/download/1.15.0.6/pandoc-1.15.0.6-1-amd64.deb /pandoc.deb
RUN export DEBIAN_FRONTEND=noninteractive \
    && dpkg -i /pandoc.deb \
    && rm /pandoc.deb

RUN git clone https://github.com/jgm/pandocfilters.git /pandocfilters \
    && cd /pandocfilters \
    && python setup.py install \
    && cp examples/*.py /usr/bin \
    && ls examples/*.py > /installed-pandocfilters.txt \
    && rm -rf /pandocfilters

RUN mkdir -p /source
WORKDIR /source

VOLUME ["/source"]
ENTRYPOINT ["/start.sh"]
CMD ["--help"]

# Add startscript
ADD adds/start.sh /start.sh
ADD readme.md /readme.docker.md
RUN chmod 777 /start.sh
