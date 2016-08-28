#! /bin/bash

#out directories
ARMV7_OUT_DIR="out_android_armv7"
ARM64_OUT_DIR="out_android_arm64"
X86_OUT_DIR="out_android_x86"
X64_OUT_DIR="out_android_x64"

ARCH_ARM64=0
ARCH_ARMV7=0
ARCH_X86=0
ARCH_X64=0

#help
me=$(basename $0)
HELP_INFO="$me [arch/--allarch]\n Existing arches: armv7 arm64 i386 x86_64"

WEBRTC_TARGET="AppRTCDemo"
#WEBRTC_TARGET="libjingle_peerconnection_so"

if [ $* ]; then
  for input in $@
  do
    if [[ $input = "-h" || $input = "--help" ]]; then echo $HELP_INFO; exit 0; fi
    
    if [ $input = "armv7" ]; then ARCH_ARMV7=1;
    elif [ $input = "arm64" ]; then ARCH_ARM64=1;
    elif [ $input = "i386" ]; then ARCH_X86=1;
    elif [ $input = "x86_64" ]; then ARCH_X64=1;
    elif [ $input = "--allarch" ]; then 
      ARCH_ARMV7=1
      ARCH_ARM64=1
      ARCH_X86=1
      ARCH_X64=1
    else 
      ARCH_ARMV7=1
    fi
  done
else 
   ARCH_ARMV7=1
fi

ROOT_DIR=`pwd`

export GYP_CROSSCOMPILE=1

cd ./src
source ./build/android/envsetup.sh

if [ $ARCH_ARMV7 = 1 ]; then
  echo "build android armv7 library"
  export GYP_GENERATOR_FLAGS="output_dir=${ARMV7_OUT_DIR}"
  export GYP_DEFINES="OS=android host_os=linux"
  export GYP_GENERATORS="ninja"
  gclient runhooks
  #ninja -C $ARMV7_OUT_DIR/Release/ -t clean
  ninja -C $ARMV7_OUT_DIR/Release/ $WEBRTC_TARGET
fi

if [ $ARCH_ARM64 = 1 ]; then
  echo "build android arm64 library"
  export GYP_GENERATOR_FLAGS="output_dir=${ARM64_OUT_DIR}"
  export GYP_GENERATORS="ninja"
  export GYP_DEFINES="OS=android host_os=linux target_arch=arm64 target_subarch=arm64"
  gclient runhooks
  #ninja -C $ARM64_OUT_DIR/Release/ -t clean
  ninja -C $ARM64_OUT_DIR/Release/ $WEBRTC_TARGET
fi

if [ $ARCH_X86 = 1 ]; then
  echo "build android x86 library"
  export GYP_GENERATOR_FLAGS="output_dir=${X86_OUT_DIR}"
  export GYP_GENERATORS="ninja"
  export GYP_DEFINES="OS=android host_os=linux target_arch=ia32"
  gclient runhooks
  ninja -C $X84_OUT_DIR/Release/ $WEBRTC_TARGET
fi

if [ $ARCH_X64 = 1 ]; then
  echo "build android x64 library"
  export GYP_GENERATOR_FLAGS="output_dir=${X64_OUT_DIR}"
  export GYP_GENERATOR="ninja"
  export GYP_DEFINES="OS=android host_os=linux target_arch=x64"
  gclient runhooks
  ninja -C $X64_OUT_DIR/Release/ $WEBRTC_TARGET
fi


echo "WebRTC build Done"
cd $ROOT_DIR
