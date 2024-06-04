import Foundation

/// `Configuration` is an enum used to manage shared configuration settings for the SpotifyPicker package. Accessible within the package only.
public enum Configuration {
	/// A shared instance of `SpotifyPickerConfiguration`.
	static var shared = SpotifyPickerConfiguration()
}

/// `SpotifyPickerConfiguration` is a struct representing configuration settings for the SpotifyPicker library.
public struct SpotifyPickerConfiguration {
	/// The base URL for Spotify API requests.
	let apiBaseURL = "https://api.spotify.com"
	/// The base URL for Spotify authentication requests.
	let apiAuthURL = "https://accounts.spotify.com"
	/// The client ID obtained from the Spotify Developer Dashboard.
	var clientId: String = ""
	/// The client secret obtained from the Spotify Developer Dashboard.
	var clientSecret: String = ""
	/// The secret coder used for encoding and decoding client secrets.
	var secretCoder: SecretCoder = Base64SecretCoder()

	/// Initializes a SpotifyPickerConfiguration with the specified client ID and client secret.
	///
	/// - Parameters:
	///   - clientId: The client ID obtained from the Spotify Developer Dashboard.
	///   - clientSecret: The client secret obtained from the Spotify Developer Dashboard.
	public init(clientId: String, clientSecret: String) {
		self.clientId = clientId
		self.clientSecret = clientSecret
	}

	/// Initializes a SpotifyPickerConfiguration with the specified client ID, client secret, and secret coder.
	///
	/// - Parameters:
	///   - clientId: The client ID obtained from the Spotify Developer Dashboard.
	///   - clientSecret: The client secret obtained from the Spotify Developer Dashboard.
	///   - secretCoder: The secret coder used for encoding and decoding client secrets.
	public init(clientId: String, clientSecret: String, secretCoder: SecretCoder) {
		self.clientId = clientId
		self.clientSecret = clientSecret
		self.secretCoder = secretCoder
	}

	/// Default initializer.
	init() {}
}
