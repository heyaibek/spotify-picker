import Foundation

/// `SearchManager` is a class responsible for searching tracks on Spotify API using a given search query. It caches search results to optimize performance and reduce redundant network requests.
class SearchManager: ObservableObject {
	/// A published property that indicates whether the search request is currently ongoing.
	@Published var isFetching = false

	/// A private cache to store search results for quick retrieval.
	private var cache: [String: [Track]] = [:]

	/// Fetches tracks from Spotify based on the given query.
	///
	/// - Parameter query: The search query string.
	///
	/// - Returns: An array of `Track` objects matching the search query.
	///
	/// - Throws:
	/// 	- `SpotifyError.expiredToken` if the current token is expired.
	/// 	- `SpotifyError.invalidURLComponents` if the URL components for the search endpoint are invalid.
	/// 	- `SpotifyError.invalidURL` if the constructed URL is invalid.
	/// 	- `SpotifyError.invalidHTTPResponse` if the response is not a valid HTTP response.
	/// 	- `SpotifyError.badToken` if the response status code is 401.
	/// 	- `SpotifyError.badOAuth` if the response status code is 403.
	/// 	- `SpotifyError.rateLimitExceeded` if the response status code is 429.
	/// 	- `SpotifyError.unknownResponse(String)` for other status codes with the error message from the response.
	@MainActor
	func fetchTracks(query: String) async throws -> [Track] {
		isFetching = true

		if let cachedResult = cache[query] {
			return cachedResult
		}

		guard let accessToken = TokenStore.shared.currentToken else {
			throw SpotifyError.expiredToken
		}

		guard var components = URLComponents(string: Configuration.shared.apiBaseURL.appending("/v1/search")) else {
			throw SpotifyError.invalidURLComponents
		}

		components.queryItems = [
			URLQueryItem(name: "q", value: query.trimmingCharacters(in: .whitespacesAndNewlines)),
			URLQueryItem(name: "type", value: "track"),
		]

		guard let url = components.url else {
			throw SpotifyError.invalidURL
		}

		let request = buildRequest(for: url, accessToken: accessToken)
		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else {
			throw SpotifyError.invalidHTTPResponse
		}

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase

		isFetching = false

		switch httpResponse.statusCode {
		case 200:
			let response = try decoder.decode(SearchResponse.self, from: data)
			let result = response.tracks.items

			// cache result
			cache[query] = result

			return result
		case 401: throw SpotifyError.badToken
		case 403: throw SpotifyError.badOAuth
		case 429: throw SpotifyError.rateLimitExceeded
		default:
			let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
			throw SpotifyError.unknownResponse(errorResponse.error.message)
		}
	}

	/// Constructs a URLRequest for the given URL with necessary headers, including the access token.
	///
	/// - Parameters:
	///   - url: The URL for the search request.
	///   - accessToken: The current access token for authentication.
	///
	/// - Returns: A configured URLRequest.
	private func buildRequest(for url: URL, accessToken: String) -> URLRequest {
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.allHTTPHeaderFields = [
			"Accept": "application/json; charset=utf-8",
			"Authorization": "Bearer \(accessToken)",
		]
		return request
	}
}
