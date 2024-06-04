
/// A cover art object of Spotify API.
public struct Artwork: Codable {
	/// The source URL of the image.
	public var url: String
	/// The image width in pixels.
	public var width: Int
	/// The image height in pixels.
	public var height: Int
}

/// Spotify API provides 3 types of image size. The `ArtworkVariant` enum maps the sizes accordingly.
public enum ArtworkVariant: Int {
	/// Represents an image size with 64px
	case small
	/// Represents an image size with 300px
	case regular
	/// Represents an image size with 600px
	case large

	/// - Returns: Size in pixels.
	var size: Int {
		switch self {
		case .small: 64
		case .regular: 300
		case .large: 640
		}
	}
}
