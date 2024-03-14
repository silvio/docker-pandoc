# this dockerfile is an import from https://registry.hub.docker.com/u/jagregory/pandoc/dockerfile/
# I have done some changes

FROM debian:bullseye

#MAINTAINER James Gregory <james@jagregory.com>
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>

RUN ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

RUN echo "deb http://httpredir.debian.org/debian bullseye contrib" > /etc/apt/sources.list.d/contrib.list ;\
    echo "deb http://httpredir.debian.org/debian bullseye-updates contrib" >> /etc/apt/sources.list.d/contrib.list ;\
    echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list.d/contrib.list

# install haskell
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
              abcm2ps \
              ca-certificates \
              cm-super \
              curl \
              fontconfig \
              fonts-liberation \
              git \
              graphviz \
              imagemagick \
              inotify-tools \
              make \
              python3-pygraphviz \
              python3-setuptools \
              python3 \
              texlive-bibtex-extra \
              texlive-fonts-extra \
              texlive-lang-all \
              texlive-latex-base \
              texlive-latex-extra \
              texlive-science \
              texlive-xetex \
              wget \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ENV PKGREL 1
ENV VERSION 3.1.12.2
ADD https://github.com/jgm/pandoc/releases/download/${VERSION}/pandoc-${VERSION}-${PKGREL}-amd64.deb /pandoc.deb
RUN export DEBIAN_FRONTEND=noninteractive \
    && dpkg -i /pandoc.deb \
    && rm /pandoc.deb

RUN git clone https://github.com/jgm/pandocfilters.git /pandocfilters \
    && cd /pandocfilters \
    && python3 setup.py install \
    && cp examples/*.py /usr/bin \
    && ls examples/*.py > /installed-pandocfilters.txt \
    && rm -rf /pandocfilters

ADD https://raw.githubusercontent.com/silvio/pandocfilters/sfr/git-diff-filter/examples/git-diff.py /usr/bin/git-diff.py
RUN echo "examples/git-diff.py" >> /installed-pandocfilters.txt

RUN sed -i 's#examples#/usr/bin#' /installed-pandocfilters.txt

RUN mkdir -p /source
WORKDIR /source

VOLUME ["/source"]
ENTRYPOINT ["/start.sh"]
CMD ["--help"]

# Add startscript
ADD adds/start.sh /start.sh
ADD readme.md /readme.docker.md
RUN chmod 777 /start.sh
