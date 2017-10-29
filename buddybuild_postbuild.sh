#!/usr/bin/env bash

xcodebuild clean test -project ImagineEngine.xcodeproj -scheme ImagineEngine-macOS -destination "platform=OS X" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO
xcodebuild clean test -project ImagineEngine.xcodeproj -scheme ImagineEngine-tvOS -destination "platform=tvOS Simulator,name=Apple TV 1080p" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO
