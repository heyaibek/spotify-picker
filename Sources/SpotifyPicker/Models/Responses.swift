import Foundation

/// Tracks object of Spotify API.
struct TracksObject: Codable {
	/// Array of `Track`s
	var items: [Track]
	/// The offset of the items returned (as set in the query or by default).
	var offset: Int
	/// The maximum number of items in the response (as set in the query or by default).
	var limit: Int
	/// The total number of items available to return.
	var total: Int
}

/// An Error object of Spotify API.
struct ErrorObject: Codable {
	/// The HTTP status code (also returned in the response header). Range: `400 - 599`.
	var status: Int
	/// A short description of the cause of the error.
	var message: String
}

/// An error response object of Spotify API.
struct ErrorResponse: Codable {
	var error: ErrorObject
}

/// A search response object of Spotify API.
struct SearchResponse: Codable {
	var tracks: TracksObject
}

/// A token response object of Spotify API.
struct TokenResponse: Codable {
	/// An access token that can be provided in subsequent calls.
	var accessToken: String
	/// How the access token may be used: always "Bearer".
	var tokenType: String
	/// The time period (in seconds) for which the access token is valid.
	var expiresIn: Int
}
