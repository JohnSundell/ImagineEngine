Pod::Spec.new do |s|
  s.name         = "ImagineEngine"
  s.version      = "0.5.0"
  s.summary      = "A Swift game engine based on Core Animation"
  s.description  = <<-DESC
    Imagine Engine is an ongoing project that aims to create a fast, high-performace Swift 2D game engine for Apple's platforms that is also a joy to use.
    While there are still ways to go, things to fix and new capabilities to add, you are invited to participate in this new community to build a tool with
    an ambitious but clear goal - to enable you to easily build any game that you can imagine.
  DESC
  s.homepage     = "https://github.com/JohnSundell/ImagineEngine"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "John Sundell" => "john@sundell.co" }
  s.social_media_url   = "https://twitter.com/johnsundell"
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.12"
  s.tvos.deployment_target = "10.0"
  s.source       = { :git => "https://github.com/JohnSundell/ImagineEngine.git", :tag => s.version.to_s }
  s.source_files = "Sources/Core/**/*.swift"
  s.ios.source_files = "Sources/Integrations/UIKit/*.swift"
  s.ios.exclude_files = [
      "Sources/Core/Internal/ClickGestureRecognizer-macOS.swift",
      "Sources/Core/Internal/DisplayLink-macOS.swift",
      "Sources/Core/Internal/EdgeInsets-macOS.swift",
      "Sources/Core/Internal/Image-macOS.swift",
      "Sources/Core/Internal/Screen-macOS.swift"
  ]
  s.osx.source_files = "Sources/Integrations/AppKit/*.swift"
  s.osx.exclude_files = [
      "Sources/Core/Internal/DisplayLink-iOS+tvOS.swift",
      "Sources/Core/Internal/Screen-iOS.swift"
  ]
  s.tvos.source_files = "Sources/Integrations/UIKit/*.swift"
  s.tvos.exclude_files = [
      "Sources/Core/Internal/ClickGestureRecognizer-macOS.swift",
      "Sources/Core/Internal/DisplayLink-macOS.swift",
      "Sources/Core/Internal/EdgeInsets-macOS.swift",
      "Sources/Core/Internal/Image-macOS.swift",
      "Sources/Core/Internal/Screen-macOS.swift"
  ]
  s.frameworks  = "Foundation", "CoreGraphics", "QuartzCore"
end
