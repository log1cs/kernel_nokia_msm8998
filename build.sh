#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
export CLANG_PATH=/home/log1cs/toolchains/neutron-clang/bin
export PATH=${CLANG_PATH}:${PATH}
export CROSS_COMPILE=${CLANG_PATH}/aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=${CLANG_PATH}/arm-linux-gnueabi-
export THINLTO_CACHE=~/ltocache/
DEFCONFIG="nb1_defconfig"

VER="r1.0"

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR=/home/log1cs/AnyKernel3
ZIP_MOVE=/home/log1cs/kernel

# Functions
function clean_all {
		rm -rf $REPACK_DIR/Image*
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make LLVM=1 LLVM_IAS=1 CC=clang $DEFCONFIG
		make LLVM=1 LLVM_IAS=1 CC=clang -j$(grep -c ^processor /proc/cpuinfo)

}

function make_zip {
                cp out/arch/arm64/boot/Image.gz-dtb $REPACK_DIR
		cd $REPACK_DIR
		zip -r9 `echo $ZIP_NAME`.zip *
		mv  `echo $ZIP_NAME`*.zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")


echo -e "${green}"
echo "Building kernel..."
echo -e "${restore}"


# Vars
BASE_AK_VER="Lycoris-"
DATE=`date +"%Y%m%d-%H%M"`
AK_VER="$BASE_AK_VER$VER"
ZIP_NAME="$AK_VER"-"$DATE"
#export LOCALVERSION=~`echo $AK_VER`
#export LOCALVERSION=~`echo $AK_VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=log1cs
export KBUILD_BUILD_HOST=Lycoris

echo

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build?" dchoice
do
case "$dchoice" in
	y|Y )
		make_kernel
                make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done


echo -e "${green}"
echo "Kernel build completed."
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
