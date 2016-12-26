#!/bin/bash
SCRIPT_OUT_DIR="$HOME/git/webrtcbuilds/out"
WEBRTC_PATH="$SCRIPT_OUT_DIR/src"
BUILD_OUT_DIR="out/Release"
TMP_DIR="/tmp/_tmp_webrtc_jar"
FINAL_DIR="_final_"
TOOLCHAIN_PATH="$WEBRTC_PATH/third_party/android_tools/ndk/toolchains"
LABEL="webrtc-14500-M55-android"

function getWebRTCJniJar() {
	rm -rf "$TMP_DIR"
	mkdir -p "$TMP_DIR"
	yes | unzip "$WEBRTC_PATH/$BUILD_OUT_DIR/lib.java/webrtc/base/base_java.jar" -d "$TMP_DIR"
	yes | unzip "$WEBRTC_PATH/$BUILD_OUT_DIR/lib.java/webrtc/api/libjingle_peerconnection_java.jar" -d "$TMP_DIR"
	jar -cvf "libjingle_peerconnection.jar" -C $TMP_DIR .
	mv "libjingle_peerconnection.jar" "./$FINAL_DIR/libs/libjingle_peerconnection.jar"
	rm -rf "$TMP_DIR"
}

function stripWebRTC() {
	# --- arm
	_from="$SCRIPT_OUT_DIR/$LABEL-arm/lib/Release/libjingle_peerconnection_so.so"
	_to="./$FINAL_DIR/libs/lib/armeabi-v7a/libjingle_peerconnection_so.so"
	_command="$TOOLCHAIN_PATH/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-strip"
	$_command -o $_to $_from -s

	# --- x86
	_from="$SCRIPT_OUT_DIR/$LABEL-x86/lib/Release/libjingle_peerconnection_so.so"
	_to="./$FINAL_DIR/libs/lib/x86/libjingle_peerconnection_so.so"
	_command="$TOOLCHAIN_PATH/x86-4.9/prebuilt/linux-x86_64/bin/i686-linux-android-strip"
	$_command -o $_to $_from -s
}

function packageWebRTCSo() {
	cd "$FINAL_DIR/libs"
	zip -r libjingle_peerconnection.so.jar lib
	rm -rf lib
	cd ../../
}

function generateDirs() {
	rm -rf "./$FINAL_DIR"
	mkdir -p "./$FINAL_DIR/libs"
	mkdir -p "./$FINAL_DIR/libs/lib/armeabi-v7a"
	#mkdir -p "./$FINAL_DIR/libs/lib/arm64-v8a"
	mkdir -p "./$FINAL_DIR/libs/lib/x86"
	#mkdir -p "./$FINAL_DIR/libs/lib/x86_64"
}

function main() {
	generateDirs
	getWebRTCJniJar
	stripWebRTC
	packageWebRTCSo
}

main

# --- final dir:
# libs -> libjingle_peerconnection.jar 
#	  -> libjingle_peerconnection.so.jar
# --- libjingle_peerconnection.so.jar is using `zip -r libjingle_peerconnection.so.jar lib`
# --- lib dir tree is:
# lib -> armeabi-v7a (gn: arm)
#	 -> arm64-v8a (gn: arm64)
#	 -> x86 (gn: x86)
#	 -> x86_64 (gn: x64)
