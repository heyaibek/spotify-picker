import Foundation

public enum Configuration {
	static var shared = SpotifyPickerConfiguration()
}

public struct SpotifyPickerConfiguration {
	let apiBaseURL = "https://api.spotify.com"
	let apiAuthURL = "https://accounts.spotify.com"
	var clientId: String = ""
	var clientSecret: String = ""
	var secretCoder: SecretCoder = Base64SecretCoder()

	public init(clientId: String, clientSecret: String) {
		self.clientId = clientId
		self.clientSecret = clientSecret
	}

	public init(clientId: String, clientSecret: String, secretCoder: SecretCoder) {
		self.clientId = clientId
		self.clientSecret = clientSecret
		self.secretCoder = secretCoder
	}

	init() {}
}
