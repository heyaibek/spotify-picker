import Foundation

class TokenManager: ObservableObject {
	@Published var isInvalidating = false

	@MainActor
	func invalidateToken() async throws {
		isInvalidating = true

		guard let components = URLComponents(string: Configuration.shared.apiAuthURL.appending("/api/token")) else {
			throw SpotifyError.invalidURLComponents
		}

		guard let url = components.url else {
			throw SpotifyError.invalidURL
		}

		let request = buildRequest(for: url)
		let (data, response) = try await URLSession.shared.data(for: request)
		guard let httpResponse = response as? HTTPURLResponse else {
			throw SpotifyError.invalidHTTPResponse
		}

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase

		isInvalidating = false

		switch httpResponse.statusCode {
		case 200:
			let response = try decoder.decode(TokenResponse.self, from: data)
			TokenStore.shared.persist(token: response.accessToken, expiresInSeconds: response.expiresIn)
		case 403: throw SpotifyError.badOAuth
		case 429: throw SpotifyError.rateLimitExceeded
		default:
			let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
			throw SpotifyError.unknownResponse(errorResponse.error.message)
		}
	}

	private func buildRequest(for url: URL) -> URLRequest {
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = [
			"Accept": "application/json; charset=utf-8",
		]
		request.httpBody = buildBody(parameters: [
			"grant_type": "client_credentials",
			"client_id": Configuration.shared.clientId,
			"client_secret": Configuration.shared.clientSecret,
		])
		return request
	}

	private func buildBody(parameters: [String: String]) -> Data? {
		parameters
			.map {
				let encodedValue = $1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
				return String(format: "%@=%@", $0, encodedValue ?? "")
			}
			.joined(separator: "&")
			.data(using: .utf8)
	}
}
