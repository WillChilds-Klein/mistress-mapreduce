FROM ubuntu

MAINTAINER Will Childs-Klein <will.childsklein@gmail.com>

# install dependencies and a few tools
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python \
    python-pip \
    curl \
    git

# fine ALL the bins
ENV PATH /usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin

# clone code repo and pull data
RUN mkdir -p /mistress-mapreduce \
    && git clone https://github.com/WillChilds-Klein/mistress-mapreduce.git /mistress-mapreduce \
    && mkdir -p /mistress-mapreduce/input \
    && curl -SL https://dl.dropboxusercontent.com/u/19937132/enron-email-text.tar.gz
    | tar -xzC /mistress-mapreduce/input

# set workdir and install code
WORKDIR /mistress-mapreduce
RUN python ./setup.py install

# generate input_paths.txt
RUN scripts/generate_input_paths.sh
