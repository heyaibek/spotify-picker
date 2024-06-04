import SwiftUI

struct Demo: View {
	struct SearchTerm: Identifiable {
		let id = UUID().uuidString
		let search: String
	}

	@State private var searchTerm: SearchTerm? = nil
	@State private var pickerItem: PickerItem? = nil

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
				searchTerm = SearchTerm(search: "Skrillex")
			}
		}
		.padding()
		.sheet(item: $searchTerm) { term in
			SpotifyPickerView(pickerItem: $pickerItem, search: term.search)
		}
	}
}

#Preview {
	Demo()
}
