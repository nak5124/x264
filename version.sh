#!/usr/bin/env bash
cd "$(dirname "$0")" >/dev/null && [ -f x264.h ] || exit 1

api="$(grep '#define X264_BUILD' < x264.h | sed 's/^.* \([1-9][0-9]*\).*$/\1/')"
ver="x"
version=""
bit_depth="$(grep '#define X264_BIT_DEPTH' < x264_config.h | sed 's/^.* \([1-9][0-9]*\).*$/\1/')"
sys_arch="$(grep 'SYS_ARCH=' < config.mak | awk -F= '{print $2}' | tr "[A-Z]" "[a-z]")"
have_lavf="$(grep '#define HAVE_LAVF' < config.h | sed 's/^.* \([0-9]*\).*$/\1/')"
if [ -d .git ] && command -v git >/dev/null 2>&1 ; then
    localver="$(($(git rev-list HEAD | wc -l)))"
    if [ "$localver" -gt 1 ] ; then
        ver_diff="$(($(git rev-list origin/plain..HEAD | wc -l)))"
        ver="$((localver-ver_diff))"
        echo "#define X264_REV $ver"
        echo "#define X264_REV_DIFF $ver_diff"
        if [ "$ver_diff" -ne 0 ] ; then
            ver="$ver+$ver_diff"
        fi
        if git status | grep -q "modified:" ; then
            ver="${ver}M"
        fi
        if [ "$have_lavf" -eq 1 ] ; then
            ver="${ver} [${sys_arch} ${bit_depth}bit-depth]"
        else
            ver="${ver} [lite ${sys_arch} ${bit_depth}bit-depth]"
        fi
        version=" r$ver"
    fi
fi

echo "#define X264_VERSION \"$version\""
echo "#define X264_POINTVER \"0.$api.$ver\""
