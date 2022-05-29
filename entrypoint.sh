#!/usr/bin/bash
# /src is the kernel source location
# /build is a tmpfs

mkdir /build/toolchain
cd /build/toolchain
curl https://ftp.travitia.xyz/clang/clang-78650b78618840563a05d840794519422998adbb.tar.xz | tar -xJ

git clone --single-branch -b main --depth 1 https://github.com/DavinciCodeOS/AnyKernel3.git /build/anykernel

export PATH="/build/toolchain/bin:$PATH"
export KBUILD_BUILD_USER=adrian
export KBUILD_BUILD_HOST=syndra

cd /src
make O=out ARCH=arm64 LLVM=1 LLVM_IAS=1 davinci_defconfig
make -j$(nproc) \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi-

FILENAME=vantom-$(date +"%Y%m%d-%H%M").zip

cd /build/anykernel
rm -rf .git README.md
cp /src/out/arch/arm64/boot/Image.gz .
cp /src/out/arch/arm64/boot/dtbo.img .
zip -r9 $FILENAME ./
mv $FILENAME /src/out/

echo "Done building. Check out/$FILENAME for the installable ZIP."
