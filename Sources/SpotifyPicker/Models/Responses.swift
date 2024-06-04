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
