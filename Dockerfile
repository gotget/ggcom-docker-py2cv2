# GGCOM - Docker - py2cv2 v201508051237
# Louis T. Getterman IV (@LTGIV)
# www.GotGetLLC.com | www.opensour.cc/ggcom/docker/py2cv2
#
# Example usage:
#
# Build
# $] docker build --tag=py2cv2 .
#
# Run
# $] docker run py2cv2 --version
# $] docker run --volume="HOST/PATH/PROJECT:/opt/PROJECT" py2cv2 "/opt/PROJECT/run.py"
#
# Thanks:
#
# Setting up pyenv in docker
# https://gist.github.com/jprjr/7667947
#
################################################################################
FROM		ubuntu:14.04.2
MAINTAINER	GotGet, LLC <contact+docker@gotgetllc.com>

ENV			DEBIAN_FRONTEND	noninteractive

RUN			apt-get -y update && apt-get -y install \
				apt-transport-https \
				curl \
				gcc \
				git-core \
				libbz2-dev \
				libreadline-dev \
				libsqlite3-dev \
				libssl-dev \
				make \
				zlib1g-dev

RUN			adduser --disabled-password --gecos "" python_user

USER		python_user
WORKDIR		/home/python_user

ENV			HOME			/home/python_user
ENV			PYENV_ROOT		$HOME/.pyenv
ENV			PATH			$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN			curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

ADD			pycompiler.bash $HOME/pycompiler.bash
RUN			bash $HOME/pycompiler.bash 2
RUN			rm -rf $HOME/pycompiler.bash

RUN			pyenv rehash

RUN			pip install --upgrade pip

ENTRYPOINT ["python"]
################################################################################
USER		root

# Install Python analytics requirements
RUN			apt-get -y install \
				build-essential \
				gfortran \
				libatlas-dev \
				libatlas3-base \
				libfreetype6-dev \
				liblapack-dev \
				libopenblas-dev \
				libpng12-dev \
				libzbar-dev \
				pkg-config \
				python-dev
################################################################################
USER		python_user

RUN			pip install numpy
RUN			pip install scipy
RUN			pip install matplotlib
RUN			pip install ipython
RUN			pip install pandas
RUN			pip install Pillow
RUN			pip install scikit-learn
RUN			pip install scikit-image
RUN			pip install mahotas
RUN			pip install zbar
################################################################################
USER		root

# Install OpenCV requirements
RUN			apt-get -y install \
				build-essential \
				cmake \
				git \
				libavcodec-dev \
				libavformat-dev \
				libdc1394-22-dev \
				libgtk2.0-dev \
				libjasper-dev \
				libjpeg-dev \
				libpng-dev \
				libswscale-dev \
				libtbb-dev \
				libtbb2 \
				libtiff-dev \
				pkg-config
################################################################################
USER		python_user

# Clone OpenCV 2.4.9 from GitHub (SourceForge malware potential?!  NO, THANK YOU!)
# (2.4.9.1 results in failure: "cannot find -lippicv".  So, we're holding back a version, for now.)
# (We also stick with 2.4 in order to guarantee compatibility with several projects, such as PyImageSearch)
RUN			mkdir -p $HOME/src/opencv
RUN			git clone https://github.com/Itseez/opencv.git --branch 2.4.9 --single-branch $HOME/src/opencv

# Compile OpenCV
RUN			mkdir -p $HOME/src/opencv/release
WORKDIR		$HOME/src/opencv/release
RUN			cmake \
				-D CMAKE_BUILD_TYPE=RELEASE \
				-D CMAKE_INSTALL_PREFIX="$HOME/usr/local" \
				-D BUILD_NEW_PYTHON_SUPPORT=ON \
				-D INSTALL_C_EXAMPLES=ON \
				-D INSTALL_PYTHON_EXAMPLES=ON \
				-D BUILD_EXAMPLES=ON \
				..

# Install OpenCV
RUN			make && make install

# Return to home
WORKDIR		$HOME

# Create symbolic links for Python to use
RUN			find "$HOME/usr/local/lib" -path "*site-packages*" \( -name 'cv.py' -o -name 'cv2.so' \) -print0 | \
				xargs -0 \
					ln -s -v -t \
						$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")

# Clean-up after ourselves
RUN			rm -rf $HOME/src/ $HOME/.cache/pip/ /tmp/*
################################################################################
USER root

ADD			init.bash /root/init.bash
ENTRYPOINT	[ "/bin/bash", "/root/init.bash" ]
################################################################################
