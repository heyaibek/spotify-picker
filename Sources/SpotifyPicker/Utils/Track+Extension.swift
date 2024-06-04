import AVFoundation

extension Track: Identifiable {}

public extension Track {
	var artistNames: String {
		artists.map(\.name).joined(separator: ", ")
	}
}

public extension Track {
	func imageURL(for variant: ArtworkVariant) -> String? {
		guard let image = album.images.filter({ $0.width == variant.size }).first else {
			return nil
		}
		return image.url
	}
}

extension Track {
	var metadata: [AVMetadataItem] {
		let item = self

		var map: [NSString: NSObject] = [
			AVMetadataKey.commonKeyAlbumName as NSString: item.album.name as NSString,
			AVMetadataKey.commonKeyTitle as NSString: item.name as NSString,
			AVMetadataKey.commonKeyArtist as NSString: item.artistNames as NSString,
		]

		if let artworkURL = imageURL(for: .large) {
			if let url = URL(string: artworkURL) {
				map[AVMetadataKey.commonKeyArtwork as NSString] = try? Data(contentsOf: url) as NSData
			}
		}

		var metadata: [AVMetadataItem] = []

		for (key, value) in map {
			let item = AVMutableMetadataItem()
			item.keySpace = .common
			item.key = key

			if key == AVMetadataKey.commonKeyArtwork as NSString {
				item.value = value as! NSData
			} else {
				item.value = value as! NSString
			}

			metadata.append(item)
		}

		return metadata
	}
}

let sampleTrack = Track(
	id: "332FKJMMK57VqmtT0IMN2y",
	previewUrl: "https://p.scdn.co/mp3-preview/8d9cb8e022d79bdbbb3894df9458a1108112eeb6?cid=367c1c488b2e4afcb64bcfb6e3d7bebd",
	name: "Haywyre",
	durationMs: 120_000,
	explicit: true,
	album: Album(
		id: "12rzJevhyC7UHuI83Baw1J",
		name: "Haywyre",
		images: [
			Artwork(url: "https://i.scdn.co/image/ab67616d0000b273a40a7519a8922e9f7ee9bf82", width: 640, height: 640),
			Artwork(url: "https://i.scdn.co/image/ab67616d00001e02a40a7519a8922e9f7ee9bf82", width: 300, height: 300),
			Artwork(url: "https://i.scdn.co/image/ab67616d00004851a40a7519a8922e9f7ee9bf82", width: 64, height: 64),
		]
	),
	artists: [
		Artist(
			id: "3hkmqgBbvL82AJ2pJfhatE",
			name: "Jeffrey L Hicks"
		),
	]
)
