import Foundation

/// `TokenManager` is a class responsible for managing the Spotify API token, including invalidating and refreshing the token.
class TokenManager: ObservableObject {
	/// A published property that indicates whether the token invalidation process is currently ongoing.
	@Published var isInvalidating = false

	/// Invalidates the current token and requests a new one from Spotify.
	///
	/// - Throws:
	///		- `SpotifyError.invalidURLComponents` if the URL components for the token endpoint are invalid.
	///		- `SpotifyError.invalidURL` if the constructed URL is invalid.
	///		- `SpotifyError.invalidHTTPResponse` if the response is not a valid HTTP response.
	///		- `SpotifyError.badOAuth` if the response status code is 403.
	///		- `SpotifyError.rateLimitExceeded` if the response status code is 429.
	///		- `SpotifyError.unknownResponse(String)` for other status codes with the error message from the response.
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

	/// Constructs a URLRequest for the given URL with necessary headers and body parameters.
	///
	/// - Parameter url: The URL for the token request.
	///
	/// - Returns: A configured `URLRequest`.
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

	/// Constructs the body data for the token request from the given parameters.
	///
	/// - Parameter parameters: A dictionary of parameters to be included in the request body.
	///
	/// - Returns: The body data encoded as `application/x-www-form-urlencoded`.
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
