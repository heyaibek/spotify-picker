import SwiftUI

struct TrackView: View {
	private let track: Track
	private let action: () -> Void

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
