import Foundation

/// An item which holds the downloaded local URL and track metadata.
public struct PickerItem {
	public let track: Track
	public let localPreviewURL: URL
}

extension PickerItem: Equatable {
	public static func == (lhs: PickerItem, rhs: PickerItem) -> Bool {
		lhs.track.id == rhs.track.id
	}
}
