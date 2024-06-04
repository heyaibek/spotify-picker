import SwiftUI

struct DownloaderView: View {
	enum ViewState {
		case pending
		case downloading
		case error(Error)
		case complete
	}

	@Environment(\.dismiss) private var dismiss
	@StateObject private var downloadManager = DownloadManager()
	@State private var viewState = ViewState.pending
	@State private var error: Error? = nil

	private let track: Track
	private let onDownload: (URL) -> Void

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
