import Foundation

enum DownloadError: LocalizedError {
	case missingPreviewURL
	case invalidURL
	case invalidExportSession
	case incompatibleExportSession

	var errorDescription: String? {
		switch self {
		case .missingPreviewURL: "Selected track doesn't provide a preview URL."
		case .invalidURL: "Invalid URL."
		case .invalidExportSession: "Couldn't create an export session."
		case .incompatibleExportSession: "Incompatible export options."
		}
	}
}
