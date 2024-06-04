
public struct Artwork: Codable {
	public var url: String
	public var width: Int
	public var height: Int
}

public enum ArtworkVariant {
	case small
	case regular
	case large

	var size: Int {
		switch self {
		case .small: 64
		case .regular: 300
		case .large: 640
		}
	}
}
