# Docker image to pywFM development
FROM jfloff/alpine-python:2.7

# install needed packages
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --no-cache --update gfortran \
                                openblas-dev@community \
                                && \
    rm /var/cache/apk/*

# Due to dependencies scipy and scikit-learn have to be in different commands
# Also due to that, we can't have a requirements.txt file
RUN pip install scipy numpy && \
    pip install scikit-learn \
                pandas \
                # for PyPi package management
                # How to publish to PyPi:
                # 1) bump setup.py for the new version <VERSION>
                # 2) `python setup.py bdist_wheel`
                # 3) `twine upload dist/pywFM-<VERSION>-py2-none-any.whl`
                wheel \
                twine

# clone repo and set envorinment variable to libfm PATH
RUN git clone https://github.com/srendle/libfm /home/libfm && \
    cd /home/libfm/ && \
    # taking advantage of a bug to allow us to save model #ShameShame
    git reset --hard 91f8504a15120ef6815d6e10cc7dee42eebaab0f && \
    make all
ENV LIBFM_PATH /home/libfm/bin/

# since we will be "always" mounting the volume, we can set this up
WORKDIR /home/pywFM

# install package in development mode at the begining
CMD pip install -e . && /bin/bash
