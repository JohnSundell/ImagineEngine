#!/usr/bin/env bash

xcodebuild clean test -project ImagineEngine.xcodeproj -scheme ImagineEngine-macOS -destination "platform=OS X" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO ONLY_ACTIVE_ARCH=NO
