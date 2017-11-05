import Foundation
import CoreGraphics

/**
 *  Protocol that enables you to override how images are loaded
 *  for textures. Normally you don't have to implement this protocol,
 *  but if you have a custom image loading pipeline you can use it
 *  to integrate such a pipeline with an instance of `TextureManager`.
 */
public protocol TextureImageLoader {
    /// Load an image for a texture with a given name, scale and format
    func loadImageForTexture(named name: String, scale: Int, format: TextureFormat) -> CGImage?
}
