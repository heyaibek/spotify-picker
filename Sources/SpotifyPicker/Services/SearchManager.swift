import Foundation

class SearchManager: ObservableObject {
	@Published var isFetching = false
	private var cache: [String: [Track]] = [:]

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
