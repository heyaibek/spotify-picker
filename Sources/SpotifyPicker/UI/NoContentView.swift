import SwiftUI

struct NoContentView: View {
	private let title: LocalizedStringKey
	private let icon: Image
	private let message: String

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
