#!/usr/bin/env bash

function test_iOS {
    xcodebuild clean test \
        -project ImagineEngine.xcodeproj \
        -scheme ImagineEngine-iOS \
        -destination "platform=iOS Simulator,name=iPhone 8" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        ONLY_ACTIVE_ARCH=NO
}

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

# Make subcommands fail the build if they fail
set -eo pipefail

# Run tests on macOS + tvOS
test_iOS | xcpretty
test_macOS | xcpretty
test_tvOS | xcpretty

# Run Danger
bundle exec danger
