
public struct Track: Codable {
	public var id: String
	public var previewUrl: String?
	public var name: String
	public var durationMs: Int
	public var explicit: Bool
	public var album: Album
	public var artists: [Artist]
}
