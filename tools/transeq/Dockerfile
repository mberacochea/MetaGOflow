FROM ubuntu:18.04


RUN apt-get update && apt-get install -y --no-install-recommends build-essential libopenmpi-dev && apt-get autoremove -yqq --purge && apt-ge
t clean && rm -rf /var/lib/apt/lists/* 


RUN apt-get update -y && apt-get install -y libx11-dev #&& apt install -y  xorg


RUN apt-get install -y emboss


# Base command
CMD [ transeq ]


