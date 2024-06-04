import SwiftUI

/// `TrackView` is a SwiftUI view used to display information about a track and perform an action when tapped.
struct TrackView: View {
	/// The track to display information about.
	private let track: Track
	/// The action to perform when the view is tapped.
	private let action: () -> Void

	/// Initializes a TrackView with the specified track and action.
	///
	/// - Parameters:
	///   - track: The track to display information about.
	///   - action: The action to perform when the view is tapped.
	init(_ track: Track, action: @escaping () -> Void) {
		self.track = track
		self.action = action
	}

	public var body: some View {
		Button {
			action()
		} label: {
			HStack(spacing: 20) {
				if let imageUrl = track.imageURL(for: .small), let url = URL(string: imageUrl) {
					AsyncImage(url: url) { image in
						image
							.resizable()
					} placeholder: {
						ProgressView()
					}
					.frame(width: 48, height: 48)
					.clipShape(.rect(cornerRadius: 10))
				}
				VStack(alignment: .leading) {
					HStack {
						if track.explicit {
							Text(Image.eSquareFill)
							Text(track.name)
						} else {
							Text(track.name)
						}
					}
					.font(.headline)
					Text(track.artistNames)
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
				.lineLimit(1)
				Spacer()
				Text(track.durationMs.asSeconds.ms)
					.font(.caption)
			}
		}
		.tint(.primary)
		.disabled(track.previewUrl == nil)
	}
}

#Preview {
	TrackView(sampleTrack) {}
		.padding()
}
