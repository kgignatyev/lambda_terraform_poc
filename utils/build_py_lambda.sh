set -x

SRC_DIR=$1
BUILD_DIR=$2
pwd
cp -fR $SRC_DIR $BUILD_DIR
pip3 install -r $BUILD_DIR/requirements.txt -t $BUILD_DIR
