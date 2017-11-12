#!/usr/bin/env bash

# Run tests on macOS
xcodebuild clean test \
    -project ImagineEngine.xcodeproj \
    -scheme ImagineEngine-macOS \
    -destination "platform=OS X" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    ONLY_ACTIVE_ARCH=NO \
    | xcpretty

# Run tests on tvOS
xcodebuild clean test \
    -project ImagineEngine.xcodeproj \
    -scheme ImagineEngine-tvOS \
    -destination "platform=tvOS Simulator,name=Apple TV" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    ONLY_ACTIVE_ARCH=NO \
    | xcpretty

# Run Danger
chruby 2.3.1
bundle install
bundle exec danger
