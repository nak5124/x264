#!/usr/bin/env bash
BUILD_DIR=`pwd`/
[ -n "$1" ] && cd $1

git_version() {
trap 'rm -f config.git-hash' EXIT
git rev-list HEAD | sort > config.git-hash
LOCALVER=`wc -l config.git-hash | awk '{print $1}'`
BIT_DEPTH=`grep "X264_BIT_DEPTH" < ${BUILD_DIR}x264_config.h | awk '{print $3}'`
BUILD_ARCH=`grep "SYS_ARCH=" < ${BUILD_DIR}config.mak | awk -F= '{print $2}'`
BUILD_ARCH=`echo $BUILD_ARCH | tr "[A-Z]" "[a-z]"`
LAVF=`grep "HAVE_LAVF" < ${BUILD_DIR}config.h | awk '{print $3}'`
if [ $LOCALVER \> 1 ] ; then
    VER=`git rev-list origin/plain | sort | join config.git-hash - | wc -l | awk '{print $1}'`
    VER_DIFF=$(($LOCALVER-$VER))
    echo "#define X264_REV $VER"
    echo "#define X264_REV_DIFF $VER_DIFF"
    if [ $VER_DIFF != 0 ] ; then
        VER="$VER+$VER_DIFF"
    fi
    if git status | grep -q "modified:" ; then
        VER="${VER}M"
    fi
    if [ $LAVF == 1 ] ; then
        VER="${VER} [${BUILD_ARCH} ${BIT_DEPTH}bit-depth]"
    else
        VER="${VER} [lite ${BUILD_ARCH} ${BIT_DEPTH}bit-depth]"
    fi
    VERSION=" r$VER"
fi
}

VER="x"
VERSION=""
[ -d .git ] && (type git >/dev/null 2>&1) && git_version
echo "#define X264_VERSION \"$VERSION\""
API=`grep '#define X264_BUILD' < x264.h | sed -e 's/.* \([1-9][0-9]*\).*/\1/'`
echo "#define X264_POINTVER \"0.$API.$VER\""
