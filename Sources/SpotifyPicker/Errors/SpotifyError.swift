import Foundation

/// `SpotifyError` is an enumeration representing errors that may occur during interactions with the Spotify API.
enum SpotifyError: LocalizedError {
	/// When access token stored in `TokenStore` is expired.
	case expiredToken
	/// Invalid URL.
	case invalidURL
	/// Invalid URL components.
	case invalidURLComponents
	/// Invalid HTTP response.
	case invalidHTTPResponse
	/// The app has exceeded its rate limits.
	case rateLimitExceeded
	/// Bad OAuth request (wrong consumer key, bad nonce, expired timestamp, etc.). Re-authenticating the user won't help in this case.
	case badOAuth
	/// Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user.
	case badToken
	/// An unknown error response from the Spotify API, with the associated message.
	case unknownResponse(String)

	/// Provides localized descriptions for each error case.
	var errorDescription: String? {
		switch self {
		case .expiredToken: "An expired access token is used."
		case .invalidURL: "Invalid URL."
		case .invalidURLComponents: "Invalid URL components."
		case .invalidHTTPResponse: "Invalid HTTP response."
		case .rateLimitExceeded: "The app has exceeded its rate limits."
		case .badOAuth: "Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...). Unfortunately, re-authenticating the user won't help here."
		case .badToken: "Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user."
		case let .unknownResponse(message): "An unknown error response from Spotify API: \(message)"
		}
	}
}
