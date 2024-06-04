import Foundation

struct TracksObject: Codable {
	var items: [Track]
	var offset: Int
	var limit: Int
	var total: Int
}

struct ErrorObject: Codable {
	var status: Int
	var message: String
}

struct ErrorResponse: Codable {
	var error: ErrorObject
}

struct SearchResponse: Codable {
	var tracks: TracksObject
}

struct TokenResponse: Codable {
	var accessToken: String
	var tokenType: String
	var expiresIn: Int
}

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
		case .expiredToken: "Expired access token is used."
		case .invalidURL: "Invalid URL."
		case .invalidURLComponents: "Invalid URL components."
		case .invalidHTTPResponse: "Invalid HTTP response."
		case .rateLimitExceeded: "The app has exceeded its rate limits."
		case .badOAuth: "Bad OAuth request (wrong consumer key, bad nonce, expired timestamp...). Unfortunately, re-authenticating the user won't help here."
		case .badToken: "Bad or expired token. This can happen if the user revoked a token or the access token has expired. You should re-authenticate the user."
		case let .unknownResponse(message): "Unknown response from Spotify API with: \(message)"
		}
	}
}
