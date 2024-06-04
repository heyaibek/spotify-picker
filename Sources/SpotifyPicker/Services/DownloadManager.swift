import AVFoundation

/// `DownloadManager` is a class responsible for downloading music previews from Spotify API and injecting metadata into the downloaded files.
class DownloadManager: ObservableObject {
	/// A published property that indicates whether a download is currently in progress.
	@Published private(set) var isDownloading = false

	/// Downloads the preview of the given track and saves it to a temporary directory with metadata injected.
	///
	/// - Parameter track: The `Track` object containing information about the track to be downloaded.
	///
	/// - Returns: A `URL` pointing to the location of the downloaded file.
	///
	/// - Throws:
	///		- `DownloadError.missingPreviewURL` if the track does not have a preview URL.
	///		- `DownloadError.invalidURL` if the preview URL is invalid.
	///		- Other errors that may occur during the metadata injection.
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

	/// Injects the provided metadata into the audio file located at the source URL and saves the result to the destination URL.
	///
	/// - Parameters:
	///   - metadata: An array of `AVMetadataItem` objects to be injected into the audio file.
	///   - source: The URL of the source audio file.
	///   - destination: The URL where the resulting file with metadata should be saved.
	///
	///	- Throws:
	///		- `DownloadError.incompatibleExportSession` if the export session is not compatible with the specified preset and file type.
	///		- `DownloadError.invalidExportSession` if the export session cannot be created.
	///		- Other errors that may occur during the export process.
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
