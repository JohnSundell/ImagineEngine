/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import CoreGraphics

/// Class that manages & faciliates the loading of textures for actors
public final class TextureManager {
    /// The image loader that should be used (default = load from bundle)
    public var imageLoader: TextureImageLoader
    /// The Error Handler that should be used (default = DefaultTextureErrorHandler)
    internal var errorHandler: TextureErrorHandler
    /// The default scale when loading textures (default = the main screen's scale)
    public var defaultScale: Int = Int(Screen.mainScreenScale)
    /// The default format when loading textures (default = PNG)
    public var defaultFormat: TextureFormat = .png
    /// Any name prefix to apply to all loaded textures (default = nil)
    /// If an actor has a name prefix of its own, this prefix will be applied first
    public var namePrefix: String?
    /// Which mode to use in case an error was encountered when loading a texture (default = .ignore)
    /// This is considered only in DEBUG mode.
    public var errorMode: ErrorMode = .ignore

    internal private(set) var cache = [String : LoadedTexture]()

    // MARK: - Init

    internal init(imageLoader: TextureImageLoader = BundleTextureImageLoader(),
                  errorHandler: TextureErrorHandler = DefaultTextureErrorHandler()) {
        self.imageLoader = imageLoader
        self.errorHandler = errorHandler
    }

    // MARK: - Public

    public func preloadTexture(named name: String,
                               scale: Int? = nil,
                               format: TextureFormat? = nil,
                               onQueue queue: DispatchQueue = .main) {
        queue.async {
            _ = self.load(Texture(name: name, format: format), namePrefix: nil, scale: scale)
        }
    }

    // MARK: - Internal

    internal func load(_ texture: Texture, namePrefix additionalNamePrefix: String?, scale: Int?) -> LoadedTexture? {
        let scale = scale ?? defaultScale
        let format = texture.format ?? defaultFormat
        var name = texture.name

        if let prefix = additionalNamePrefix {
            name = "\(prefix)\(name)"
        }

        if let prefix = namePrefix {
            name = "\(prefix)\(name)"
        }

        let cacheKey = "\(name).\(format.rawValue)"

        if let cachedTexture = cache[cacheKey] {
            return cachedTexture
        }

        if let preloadedImage = texture.image {
            guard let texture = LoadedTexture(image: preloadedImage) else {
                return nil
            }

            cache[cacheKey] = texture
            return texture
        }

        guard let image = imageLoader.loadImageForTexture(named: name, scale: scale, format: format) else {
            guard scale > 1 else {
                #if DEBUG
                let errorMessage = "Texture image named '\(name)' could not be found"

                switch errorMode {
                case .ignore:
                    break
                case .log:
                    self.errorHandler.log(errorMessage: errorMessage)
                case .assert:
                    self.errorHandler.assert(errorMessage: errorMessage)
                }
                #endif

                return nil
            }

            return load(texture, namePrefix: namePrefix, scale: scale - 1)
        }

        let texture = LoadedTexture(image: image, scale: scale)
        cache[cacheKey] = texture
        return texture
    }
}

public extension TextureManager {
    /// Enum describing various error modes that can used with `TextureManager`
    enum ErrorMode {
        /// Ignore all errors
        case ignore
        /// Log errors to the console
        case log
        /// Trigger an assertion failure when an error occured
        case assert
    }
}

private class DefaultTextureErrorHandler :TextureErrorHandler {
    func log(errorMessage: String) {
        print(errorMessage)
    }

    func assert(errorMessage: String) {
        assertionFailure(errorMessage)
    }
}
