import AVFoundation

enum DownloadError: LocalizedError {
	case missingPreviewURL
	case invalidURL
	case invalidCache
	case invalidExportSession
	case incompatibleExportSession

	var errorDescription: String? {
		switch self {
		case .missingPreviewURL: "Selected track doesn't provide a preview URL."
		case .invalidURL: "Invalid URL"
		case .invalidCache: "Invalid Cache"
		case .invalidExportSession: "Couldn't create an export session"
		case .incompatibleExportSession: "Incompatible export options"
		}
	}
}

class DownloadManager: ObservableObject {
	@Published private(set) var isDownloading = false

	@MainActor
	func download(track: Track) async throws -> URL {
		isDownloading = true

		let destination = FileManager.default.temporaryDirectory.appendingPathComponent(track.id).appendingPathExtension("m4a")
		if FileManager.default.fileExists(atPath: destination.path) {
			return destination
		}

		guard let previewUrl = track.previewUrl else {
			throw DownloadError.missingPreviewURL
		}

		guard let url = URL(string: previewUrl) else {
			throw DownloadError.invalidURL
		}

		let (tmp, _) = try await URLSession.shared.download(from: url)
		let source = FileManager.default.temporaryDirectory.appendingPathComponent(track.id).appendingPathExtension("mp3")

		if FileManager.default.fileExists(atPath: source.path) {
			try FileManager.default.removeItem(at: source)
		}

		try FileManager.default.moveItem(at: tmp, to: source)
		try await injectMetadata(metadata: track.metadata, source: source, destination: destination)
		try FileManager.default.removeItem(at: source)

		isDownloading = false

		return destination
	}

	private func injectMetadata(metadata: [AVMetadataItem], source: URL, destination: URL) async throws {
		let asset = AVAsset(url: source)
		let preset = AVAssetExportPresetAppleM4A
		let type = AVFileType.m4a

		guard await AVAssetExportSession.compatibility(ofExportPreset: preset, with: asset, outputFileType: type) else {
			throw DownloadError.incompatibleExportSession
		}

		guard let exporter = AVAssetExportSession(asset: asset, presetName: preset) else {
			throw DownloadError.invalidExportSession
		}

		let duration = try await asset.load(.duration)

		exporter.outputURL = destination
		exporter.outputFileType = type
		exporter.metadata = metadata
		exporter.timeRange = CMTimeRangeMake(start: .zero, duration: duration)

		await exporter.export()
	}
}
