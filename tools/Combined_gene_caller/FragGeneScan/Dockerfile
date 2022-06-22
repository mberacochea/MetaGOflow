FROM ubuntu:18.04 as build

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             FragGeneScan
# Software Version:     1.31
# Description:          https://github.com/EBI-Metagenomics/fraggenescan
##############################################################
# RUN apk add --no-cache build-base git

RUN apt-get update --fix-missing && \
    apt-get install -y git wget make gcc && \
    apt purge --auto-remove cmake && \
    wget https://github.com/Kitware/CMake/releases/download/v3.21.4/cmake-3.21.4.tar.gz &&\
    tar -xzvf cmake-3.21.4.tar.gz

WORKDIR /

RUN git clone https://github.com/EBI-Metagenomics/fraggenescan.git && \
    cd fraggenescan && make && make clean && make fgs


RUN mkdir tools 

COPY run_FGS.sh /tools/

# COPY --from=build /fraggenescan /fraggenescan

RUN chmod a+x /tools/*

ENV PATH="/fraggenescan:/tools:${PATH}"

CMD ["run_FGS.sh"]