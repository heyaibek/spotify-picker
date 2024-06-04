
/// A track object of Spotify API.
public struct Track: Codable {
	/// The Spotify ID for the track.
	public var id: String
	/// A link to a 30 second preview (MP3 format) of the track. Can be nil.
	public var previewUrl: String?
	/// The name of the track.
	public var name: String
	/// The track length in milliseconds.
	public var durationMs: Int
	/// Whether or not the track has explicit lyrics ( true = yes it does; false = no it does not OR unknown).
	public var explicit: Bool
	/// The album on which the track appears.
	public var album: Album
	/// The artists who performed the track.
	public var artists: [Artist]
}
