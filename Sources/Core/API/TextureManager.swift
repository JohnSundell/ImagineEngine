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
    /// The default scale when loading textures (default = the main screen's scale)
    public var defaultScale: Int = Int(Screen.mainScreenScale)

    internal private(set) var cache = [String : LoadedTexture]()

    // MARK: - Init

    internal init(imageLoader: TextureImageLoader = BundleTextureImageLoader()) {
        self.imageLoader = imageLoader
    }

    // MARK: - Public

    public func preloadTexture(named name: String, scale: Int? = nil, onQueue queue: DispatchQueue = .main) {
        queue.async {
            _ = self.load(Texture(name: name), namePrefix: nil, scale: scale)
        }
    }

    // MARK: - Internal

    internal func load(_ texture: Texture, namePrefix: String?, scale: Int?) -> LoadedTexture? {
        let scale = scale ?? defaultScale
        var name = texture.name

        if let prefix = namePrefix {
            name = "\(prefix)\(name)"
        }

        if let cachedTexture = cache[name] {
            return cachedTexture
        }

        if let preloadedImage = texture.image {
            guard let texture = LoadedTexture(image: preloadedImage) else {
                return nil
            }

            cache[name] = texture
            return texture
        }

        guard let image = imageLoader.loadImageForTexture(named: name, scale: scale) else {
            guard scale > 1 else {
                return nil
            }
            return load(texture, namePrefix: namePrefix, scale: scale - 1)
        }

        let texture = LoadedTexture(image: image, scale: scale)
        cache[name] = texture
        return texture
    }
}
