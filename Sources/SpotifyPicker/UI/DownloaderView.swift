import SwiftUI

/// `DownloaderView` is a SwiftUI view used to display the download progress and status of a track.
struct DownloaderView: View {
	/// The `ViewState` enum is used to represent the different states of the download process within the `DownloaderView`. Each case of the enum corresponds to a different state of the download:
	enum ViewState {
		/// This state indicates that the download is pending, i.e., it has not started yet.
		case pending
		/// This state indicates that the download is in progress.
		case downloading
		/// This state indicates that an error occurred during the download process. The associated value contains the error that occurred.
		case error(Error)
		/// This state indicates that the download is complete.
		case complete
	}

	@Environment(\.dismiss) private var dismiss
	@StateObject private var downloadManager = DownloadManager()
	@State private var viewState = ViewState.pending

	/// The track to be downloaded.
	private let track: Track
	/// The closure to be executed when the download is complete, taking the downloaded file URL as a parameter.
	private let onDownload: (URL) -> Void

	/// Initializes a `DownloaderView` with the specified track and closure to be executed upon download completion.
	/// - Parameters:
	///   - track: The track to be downloaded.
	///   - onDownload: The closure to be executed when the download is complete, taking the downloaded file URL as a parameter.
	init(track: Track, onDownload: @escaping (URL) -> Void) {
		self.track = track
		self.onDownload = onDownload
	}

	var body: some View {
		VStack {
			Text(track.album.name)
				.font(.title)
				.fontWeight(.bold)
			Text(track.artistNames)
				.font(.title3)
			if let imageUrl = track.imageURL(for: .regular), let url = URL(string: imageUrl) {
				AsyncImage(url: url) { image in
					image
						.resizable()
				} placeholder: {
					ProgressView()
				}
				.frame(width: 100, height: 100)
				.clipShape(.rect(cornerRadius: 10))
				.padding(.vertical)
			}
			switch viewState {
			case .pending:
				ProgressView("Waiting to download...")
					.progressViewStyle(.circular)
			case .downloading:
				ProgressView("Downloading preview...")
					.progressViewStyle(.circular)
			case let .error(error):
				NoContentView(
					"Something went wrong",
					icon: .exclamationmarkTriangle,
					message: error.localizedDescription
				)
			case .complete:
				NoContentView(
					"Download Complete",
					icon: .checkmarkSeal,
					message: "You can close this view."
				)
				Button("Close") {
					dismiss()
				}
			}
		}
		.multilineTextAlignment(.center)
		.padding()
		.interactiveDismissDisabled()
		.onAppear {
			Task {
				await startDownload()
			}
		}
	}

	private func startDownload() async {
		viewState = .downloading
		do {
			try await onDownload(downloadManager.download(track: track))
			viewState = .complete
		} catch {
			viewState = .error(error)
		}
	}
}

#Preview {
	DownloaderView(track: sampleTrack) { _ in }
}
