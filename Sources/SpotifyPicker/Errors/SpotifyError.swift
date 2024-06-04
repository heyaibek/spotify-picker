import Foundation

enum SpotifyError: LocalizedError {
	case expiredToken
	case invalidURL
	case invalidURLComponents
	case invalidHTTPResponse
	case rateLimitExceeded
	case badOAuth
	case badToken
	case unknownResponse(String)

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
