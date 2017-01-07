FROM ubuntu:16.04


MAINTAINER David Semedo <df.semedo@campus.fct.unl.pt>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 git


# Necessary packages and FFmpeg
RUN apt-get -y install autoconf automake build-essential apt-utils cmake libass-dev libfreetype6-dev \
  libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \ 
  libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev ffmpeg libavcodec-dev libavformat-dev libavresample-dev \
  libjpeg-dev libjasper-dev libdc1394-22-dev \
  libopencv-dev libav-tools python-pycurl \
  libatlas-base-dev gfortran webp libvtk6-dev zlib1g-dev


#############################################
# Anaconda Python 2.7
#############################################
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget https://repo.continuum.io/archive/Anaconda2-4.2.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

ENV PATH /opt/conda/bin:$PATH

RUN conda update -y conda && \
	conda update -y numpy && \
	conda update -y scipy && \
	conda update -y pandas && \
	conda update -y matplotlib && \
	conda update -y requests && \
        conda install -c conda-forge pika=0.10.0 && \
	conda install scikit-image && \
	pip install --upgrade pip && \
	pip install --upgrade  git+git://github.com/Theano/Theano.git && \
	pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip && \
	pip install pyscenedetect --upgrade --no-dependencies

RUN echo -e "[global]\nfloatX = float32\ndevice = cpu\nopenmp = True" >> ~/.theanorc



#############################################
# OpenCV 3 w/ Python 2.7 from Anaconda
#############################################

RUN cd ~/ &&\
    git clone https://github.com/opencv/opencv.git &&\
    git clone https://github.com/opencv/opencv_contrib.git &&\
    cd opencv && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/opt/opencv -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules INSTALL_PYTHON_EXAMPLES=ON  -D BUILD_EXAMPLES=ON -D PYTHON_DEFAULT_EXECUTABLE=/opt/conda/bin/python2.7  BUILD_opencv_python2=True -D PYTHON_LIBRARY=/opt/conda/lib/libpython2.7.so -D PYTHON_INCLUDE_DIR=/opt/conda/include/python2.7 -D PYTHON2_NUMPY_INCLUDE_DIRS=/opt/conda/lib/python2.7/site-packages/numpy/core/include -D PYTHON_EXECUTABLE=/opt/conda/bin/python2.7 -DWITH_FFMPEG=ON -D BUILD_SHARED_LIBS=ON .. &&\
    make -j4 && make install && ldconfig


ENV PYTHONPATH /opt/opencv/lib/python2.7/site-packages:$PYTHONPATH



CMD [ "/bin/bash" ]
