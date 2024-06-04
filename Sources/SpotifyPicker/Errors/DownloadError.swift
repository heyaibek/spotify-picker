import Foundation

/// `DownloadError` is an enumeration representing errors that may occur during the downloading and metadata injection process in the `DownloadManager`.
enum DownloadError: LocalizedError {
	/// Thrown when the selected track doesn't provide a preview URL.
	case missingPreviewURL
	/// Thrown when the URL provided is invalid.
	case invalidURL
	/// Thrown when the export session cannot be created.
	case invalidExportSession
	/// Thrown when the export session is not compatible with the specified preset and file type.
	case incompatibleExportSession

	/// Provides localized descriptions for each error case.
	var errorDescription: String? {
		switch self {
		case .missingPreviewURL: "Selected track doesn't provide a preview URL."
		case .invalidURL: "Invalid URL."
		case .invalidExportSession: "Couldn't create an export session."
		case .incompatibleExportSession: "Incompatible export options."
		}
	}
}
