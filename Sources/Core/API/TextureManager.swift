/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import CoreGraphics

/// Class that manages & faciliates the loading of textures for actors
public final class TextureManager {
    /// Any custom image loader that should be used (nil = load from bundle)
    public var imageLoader: TextureImageLoader?
    /// The default scale when loading textures (default = the main screen's scale)
    public var defaultScale: Int = Int(Screen.mainScreenScale)

    internal private(set) var cache = [String : LoadedTexture]()
    private let bundle: Bundle

    // MARK: - Init

    internal init(bundle: Bundle = .main) {
        self.bundle = bundle
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

        if scale > 1 {
            name.append("@\(scale)x")
        }

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

        guard let image = loadImage(named: name) else {
            guard scale > 1 else {
                return nil
            }
            return load(texture, namePrefix: namePrefix, scale: scale - 1)
        }

        let texture = LoadedTexture(image: image, scale: scale)
        cache[name] = texture
        return texture
    }

    // MARK: - Private

    private func loadImage(named name: String) -> CGImage? {
        if let imageLoader = imageLoader {
            return imageLoader.loadImageForTexture(named: name)
        }

        guard let url = bundle.url(forResource: name, withExtension: "png") else {
            return nil
        }

        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            return nil
        }

        return CGImage(pngDataProviderSource: dataProvider,
                       decode: nil,
                       shouldInterpolate: false,
                       intent: .defaultIntent)
    }
}
