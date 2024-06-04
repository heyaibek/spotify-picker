import SwiftUI

struct Demo: View {
	struct SearchTerm: Identifiable {
		let id = UUID().uuidString
		let search: String
	}

	private let configuration: SpotifyPickerConfiguration

	@State private var searchTerm: SearchTerm? = nil
	@State private var pickerItem: PickerItem? = nil

	init() {
		configuration = SpotifyPickerConfiguration(
			clientId: ProcessInfo.processInfo.environment["SPOTIFY_CLIENT_ID"]!,
			clientSecret: ProcessInfo.processInfo.environment["SPOTIFY_CLIENT_SECRET"]!
		)
	}

	var body: some View {
		VStack(spacing: 20) {
			if let pickerItem {
				Text(pickerItem.track.artistNames)
				Text(pickerItem.track.name)
				Text(pickerItem.localPreviewURL.path)
			}
			Button("Clear UserDefaults") {
				UserDefaults.standard.removeObject(forKey: "spotify-picker")
			}
			Button("Open Picker") {
				searchTerm = SearchTerm(search: "")
			}
			Button("Open Picker With Search") {
				searchTerm = SearchTerm(search: "Dabeul")
			}
		}
		.padding()
		.sheet(item: $searchTerm) { term in
			SpotifyPickerView(configuration: configuration, pickerItem: $pickerItem, search: term.search)
		}
		.onChange(of: pickerItem) { item in
			if let item {
				print(item.localPreviewURL)
			}
		}
	}
}

#Preview {
	Demo()
}
