FROM alpine:3.10.5
LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>, Haris Zafeiropoulos <haris-zaf@hcmr.gr>"

########################################################################
# Dockerfile Version:   19.03.2
# Software:             eggNOG
# Software Version:     2.1.8
# Description:          functional annotation of novel sequences
########################################################################

ENV VERSION=2.1.8
ENV VERSION_DIAMOND=2.0.15

RUN apk add --no-cache bash git build-base zlib-dev python3-dev cmake linux-headers
RUN python3 -m pip install psutil biopython

# install diamond
RUN wget https://github.com/bbuchfink/diamond/archive/v$VERSION_DIAMOND.tar.gz && \
    tar -xzf v$VERSION_DIAMOND.tar.gz && \
    cd diamond-$VERSION_DIAMOND && mkdir bin && cd bin && cmake .. && make -j4  && make install

ENV PATH="/diamond-$VERSION_DIAMOND:${PATH}"

# eggnog
RUN wget https://github.com/eggnogdb/eggnog-mapper/archive/$VERSION.tar.gz 
RUN tar -xzf *$VERSION.tar.gz

ENV PATH="/eggnog-mapper-$VERSION/eggnogmapper:/eggnog-mapper-$VERSION:${PATH}"

RUN ln -s /diamond-$VERSION_DIAMOND/bin/diamond /eggnog-mapper-$VERSION/diamond

CMD ["emapper.py"]
