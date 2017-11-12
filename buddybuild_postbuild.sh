#!/usr/bin/env bash

function test_macOS {
    xcodebuild clean test \
        -project ImagineEngine.xcodeproj \
        -scheme ImagineEngine-macOS \
        -destination "platform=OS X" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        ONLY_ACTIVE_ARCH=NO
}

function test_tvOS {
    xcodebuild clean test \
        -project ImagineEngine.xcodeproj \
        -scheme ImagineEngine-tvOS \
        -destination "platform=tvOS Simulator,name=Apple TV" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        ONLY_ACTIVE_ARCH=NO
}

# Run tests on macOS + tvOS
set -o pipefail && test_macOS | xcpretty
set -o pipefail && test_tvOS | xcpretty

# Run Danger
chruby 2.3.1
bundle install
bundle exec danger
