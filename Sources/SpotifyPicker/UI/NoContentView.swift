import SwiftUI

/// `NoContentView` is a SwiftUI view used to display a message when there is no content to show.
struct NoContentView: View {
	/// The localized title of the message.
	private let title: LocalizedStringKey
	/// The icon to display alongside the message.
	private let icon: Image
	/// The detailed message to display.
	private let message: String

	/// Initializes a NoContentView with the specified title, icon, and message.
	///
	/// - Parameters:
	///   - title: The localized title of the message.
	///   - icon: The icon to display alongside the message.
	///   - message: The detailed message to display.
	init(_ title: LocalizedStringKey, icon: Image, message: String) {
		self.title = title
		self.icon = icon
		self.message = message
	}

	var body: some View {
		VStack {
			icon
				.resizable()
				.frame(width: 56, height: 56)
				.aspectRatio(contentMode: .fit)
				.foregroundStyle(.secondary)
			Text(title)
				.font(.title2)
				.fontWeight(.bold)
			Text(message)
				.font(.callout)
				.foregroundStyle(.secondary)
		}
		.multilineTextAlignment(.center)
		.padding()
	}
}

#Preview {
	NoContentView("No Content", icon: .checkmarkSeal, message: "Awesome message")
}
