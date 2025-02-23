#!/bin/bash
set -e

BLUE='\033[1;34m'
NC='\033[0m'

alpine_fs="/root/alpine_pytorch"

if [ ! -d $alpine_fs ];then
    echo "Error: cannot stat '$alpine_fs' directory"
    exit 1
fi


# 1. Init Occlum Workspace
rm -rf occlum_instance
[ -d occlum_instance ] || mkdir occlum_instance
cd occlum_instance
[ -d image ] || occlum init

# 2. Copy files into Occlum Workspace and build
if [ ! -d "image/lib/python3.7" ];then
    cp -f $alpine_fs/usr/bin/python3.7 image/bin
    cp -f $alpine_fs/usr/lib/libpython3.7m.so.1.0 image/lib
    cp -f $alpine_fs/usr/lib/libpython3.so image/lib
    cp -rf $alpine_fs/usr/lib/python3.7 image/lib
    cp -f $alpine_fs/usr/lib/libopenblas.so.3 image/lib
    cp -f $alpine_fs/usr/lib/libbz2.so.1 image/lib
    cp -f $alpine_fs/usr/lib/libffi.so.6 image/lib
    cp -f $alpine_fs/usr/lib/libgcc_s.so.1 image/lib
    cp -f $alpine_fs/usr/lib/libgfortran.so.5 image/lib
    cp -f $alpine_fs/usr/lib/liblzma.so.5 image/lib
    cp -f $alpine_fs/usr/lib/libquadmath.so.0 image/lib
    cp -f $alpine_fs/lib/libz.so.1 image/lib
    cp -f ../app/sample.py image/bin
    new_json="$(jq '.resource_limits.user_space_size = "2048MB" |
                    .resource_limits.kernel_space_heap_size = "256MB" |
                    .process.default_mmap_size = "256MB"' Occlum.json)" && \
    echo "${new_json}" > Occlum.json
    SGX_MODE=SIM occlum build
fi

# 3. Run the hello world sample
echo -e "${BLUE}occlum run /bin/python3.7 /bin/sample.py${NC}"
occlum run /bin/python3.7 /bin/sample.py
