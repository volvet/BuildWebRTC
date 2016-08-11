#! /bin/sh


# out directories
IOS32_OUT_DIR="out_ios32"
IOS64_OUT_DIR="out_ios64"

# arches
ARCH_ARM64=1
ARCH_ARMV7=0
ARCH_IA32=0
ARCH_X64=0

# lipo 
LIPO_PARAM=

#help
me=$(basename $0)
HELP_INFO="$me [arch/--allarch]\nExisting arches: armv7 arm64 i386 x86_64"

WEBRTC_TARGET="libapprtc_common.a libapprtc_signaling.a librtc_sdk_common_objc.a \
    librtc_base.a libwebrtc_common.a librtc_base_approved.a libjsoncpp.a \
    libboringssl.a libfield_trial_default.a \
    librtc_sdk_peerconnection_objc.a libjingle_peerconnection.a \
    librtc_media.a libwebrtc.a libsystem_wrappers.a libvoice_engine.a \
    libcommon_audio.a libcommon_audio_neon.a libaudio_coding_module.a \
    libcng.a libaudio_encoder_interface.a libg711.a libpcm16b.a libilbc.a \
    libwebrtc_opus.a libopus.a libg722.a libisac_fix.a libisac_common.a \
    libisac_neon.a libred.a librtc_event_log.a librtc_event_log_proto.a \
    libprotobuf_lite.a libneteq.a libaudio_decoder_interface.a \
    libbuiltin_audio_decoder_factory.a libaudio_decoder_factory_interface.a \
    librent_a_codec.a libaudio_conference_mixer.a libaudio_processing.a \
    libisac.a libaudioproc_debug_proto.a libaudio_processing_neon.a \
    libwebrtc_utility.a libmedia_file.a libaudio_device.a \
    libbitrate_controller.a libpaced_sender.a librtp_rtcp.a \
    libremote_bitrate_estimator.a libcongestion_controller.a \
    libcommon_video.a libyuv.a libvideo_capture_module.a \
    libvideo_processing.a libvideo_processing_neon.a \
    libwebrtc_video_coding.a libwebrtc_h264.a \
    libwebrtc_h264_video_toolbox.a libwebrtc_i420.a \
    libvideo_coding_utility.a libwebrtc_vp8.a libvpx.a libwebrtc_vp9.a \
    libmetrics_default.a librtc_xmllite.a libexpat.a librtc_xmpp.a \
    librtc_p2p.a libusrsctplib.a libvideo_capture_module_internal_impl.a \
    librtc_pc.a libsrtp.a libsocketrocket.a"

function exec_libtool() {
  echo "Running libtool"
  libtool -static -v -o $@
}


if [ "$*" ]; then
    for input in $@
    do
        if [[ $input = "-h"  || $input = "--help" ]]; then echo $HELP_INFO; exit 0; fi

        if [ $input = "armv7" ]; then ARCH_ARMV7=1; 
        elif [ $input = "arm64" ]; then ARCH_ARM64=1;
        elif [ $input = "i386" ]; then ARCH_IA32=1;
        elif [ $input = "x86_64" ]; then ARCH_X64=1;
        elif [ $input = "--allarch" ]; then
            ARCH_ARMV7=1
            ARCH_ARM64=1
            ARCH_IA32=1
            ARCH_X64=1
        else
            ARCH_ARM64=1
        fi
    done
fi


ROOT_DIR=`pwd`


cd ./src

if [ $ARCH_ARMV7 = 1 ]; then
    echo "build ios armv7 library"

    export GYP_DEFINES="OS=ios target_arch=arm"
    export GYP_GENERATOR_FLAGS="output_dir=${IOS32_OUT_DIR}"

    ./webrtc/build/gyp_webrtc.py
    ninja -C ./$IOS32_OUT_DIR/Release-iphoneos -t clean
    ninja -C ./$IOS32_OUT_DIR/Release-iphoneos $WEBRTC_TARGET

    exec_libtool  "./${IOS32_OUT_DIR}/Release-iphoneos/libwebrtc_armv7.a" ./$IOS32_OUT_DIR/Release-iphoneos/*.a
fi

if [ $ARCH_ARM64 = 1 ]; then
    echo "build ios arm64 library"
    export GYP_DEFINES="OS=ios target_arch=arm64"
    export GYP_GENERATOR_FLAGS="output_dir=${IOS64_OUT_DIR}"

    ./webrtc/build/gyp_webrtc.py
    ninja -C ./$IOS64_OUT_DIR/Release-iphoneos -t clean
    ninja -C ./$IOS64_OUT_DIR/Release-iphoneos $WEBRTC_TARGET

    exec_libtool  "./${IOS64_OUT_DIR}/Release-iphoneos/libwebrtc_arm64.a" ./$IOS64_OUT_DIR/Release-iphoneos/*.a
fi

cd $ROOT_DIR

echo "lipo ios library"

if [ ! -e ./out ]; then mkdir ./out; fi
if [ ! -e ./out/ios ]; then mkdir ./out/ios; fi
if [ ! -e ./out/ios/libs ]; then mkdir ./out/ios/libs; fi

if [ $ARCH_ARMV7 = 1 ]; then
    LIPO_PARAM="-arch armv7 ./src/$IOS32_OUT_DIR/Release-iphoneos/libwebrtc_armv7.a"
fi

if [ $ARCH_ARM64 = 1 ]; then
    LIPO_PARAM="${LIPO_PARAM} -arch arm64 ./src/$IOS64_OUT_DIR/Release-iphoneos/libwebrtc_arm64.a"
fi

lipo -create $LIPO_PARAM  -output ./out/ios/libs/libwebrtc.a
