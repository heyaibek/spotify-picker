
/// An album object of Spotify API.
public struct Album: Codable {
	/// The Spotify ID for the album.
	public var id: String
	/// The name of the album. In case of an album takedown, the value may be an empty string.
	public var name: String
	/// The cover art for the album in various sizes, widest first.
	public var images: [Artwork]
}
