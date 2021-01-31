#!/bin/zsh
#
# Spine - Spine - MCU code for robotics.
# Copyright (C) 2019-2021 Codam Robotics
#
# This file is part of Spine.
#
# Spine is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Spine is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Spine.  If not, see <http://www.gnu.org/licenses/>.
#

BASEDIR=$(realpath $(dirname "$0"))

ROSLIB_DST_DIR=$BASEDIR/../src
LIB_PROPERTIES=$BASEDIR/../library.properties
GIT_REPO="git@github.com:autonomousrobotshq/ros_packages.git"
GIT_REPO_NAME="ros_packages"

which catkin_make || { echo "Don't forget to source setup.zsh or setup.bash first!"; exit 1; }
which cmake || exit 1
which git || exit 1

TMP_DIR=`mktemp -d`
cd $TMP_DIR && echo "Temporary folder @ $(pwd)" || exit 1

# clone ROS packages
git clone $GIT_REPO $GIT_REPO_NAME || exit 1
cd $GIT_REPO_NAME && git submodule update --init --recursive && cd $TMP_DIR || exit 1

# initialize workspace
mkdir src && cd src && catkin_init_workspace && cd .. || exit 1
mv $GIT_REPO_NAME ./src || exit 1

# build and generate ROS headers
catkin_make && source ./devel/setup.zsh && rosrun rosserial_arduino make_libraries.py .  || exit 1

# setup src directory
rm -rf $ROSLIB_DST_DIR && mkdir $ROSLIB_DST_DIR || exit 1
mv ./ros_lib/* $ROSLIB_DST_DIR && rm -rf $TMP_DIR || exit 1

# shuffle around examples folder in generated folder
rm -rf $ROSLIB_DST_DIR/../examples && mv $ROSLIB_DST_DIR/examples $ROSLIB_DST_DIR/.. \
&& mv $ROSLIB_DST_DIR/tests/* $ROSLIB_DST_DIR/../examples && rmdir $ROSLIB_DST_DIR/tests

# patches
find $ROSLIB_DST_DIR \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i 's/cstring/string\.h/g' || exit 1
find $ROSLIB_DST_DIR \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i 's/std::memcpy/memcpy/g' || exit 1
find $ROSLIB_DST_DIR/../examples/ -name "*.pde" -exec sh -c 'mv "$1" "${1%.pde}.ino"' _ {} \; # rename .pde -> .ino

# remove bad tests (they cannot be compiled with just ROSSerial or are formatted badly)
wd=$(pwd)
cd $ROSLIB_DST_DIR/../examples
BADEXAMPLES=(
				"ADC/ADC.ino" \
				"TimeTF/TimeTF.ino" \
				"ServiceServer/ServiceServer.ino" \
				"ServiceClient/ServiceClient.ino" \
				"Odom/Odom.ino" \
				"Esp8266HelloWorld/Esp8266HelloWorld.ino" \
			)
for ino in "${BADEXAMPLES[@]}"; do rm $ino; done
cd $wd

# add includes to library.properties
sed -i '/includes=/d' $LIB_PROPERTIES
tmp_f=`mktemp`
find $ROSLIB_DST_DIR -name "*.h" -exec basename {} >> $tmp_f \;
echo -n "includes=" >> $LIB_PROPERTIES
cat $tmp_f | while read lib; do echo -n "$lib, " >> $LIB_PROPERTIES; done
rm $tmp_f

echo "Succesfully regenerated ROS libraries for Arduino."
