import Foundation

/// `TokenStore` is a utility for securely storing and retrieving Spotify API tokens in `UserDefaults`.
struct TokenStore {
	/// A singleton instance of `TokenStore` with a default `userDefaultsKey` of `"spotify-picker"`.
	static let shared = TokenStore(userDefaultsKey: "spotify-picker")

	private let valueKey: String
	private let timeKey: String

	/// Initializes a new `TokenStore` with a specified `userDefaultsKey`.
	///
	/// - Parameter userDefaultsKey: The key used to store the token and expiration time in `UserDefaults`.
	init(userDefaultsKey: String) {
		valueKey = userDefaultsKey
		timeKey = userDefaultsKey.appending("-expiration-time")
	}

	private var now: TimeInterval {
		Date().timeIntervalSince1970
	}

	/// Retrieves the current valid token, decoding it if necessary. Returns nil if the token is expired or doesn't exist.
	var currentToken: String? {
		guard let token = securedCurrentToken else {
			return nil
		}
		return decode(token)
	}

	/// Retrieves the current valid token directly from `UserDefaults` without decoding. Returns nil if the token is expired or doesn't exist.
	var securedCurrentToken: String? {
		let expires = UserDefaults.standard.double(forKey: timeKey)
		if expires < now {
			return nil
		}
		return UserDefaults.standard.string(forKey: valueKey)
	}

	/// Persists the given token in UserDefaults with an expiration time.
	///
	/// - Parameters:
	///   - token: The token to be stored.
	///   - expiresInSeconds: The duration in seconds until the token expires.
	func persist(token: String, expiresInSeconds: Int) {
		if expiresInSeconds > 0 {
			let expires = now + Double(expiresInSeconds)
			UserDefaults.standard.setValue(encode(token), forKey: valueKey)
			UserDefaults.standard.setValue(expires, forKey: timeKey)
		}
	}

	/// Encodes the given string using the `secretCoder` from the `Configuration` class.
	///
	/// - Parameter string: The string to be encoded.
	///
	/// - Returns: An encoded string.
	private func encode(_ string: String) -> String {
		Configuration.shared.secretCoder.encode(string)
	}

	/// Decodes the given encoded string using the `secretCoder` from the `Configuration` class.
	///
	/// - Parameter encoded: The encoded string to be decoded.
	///
	/// - Returns: The decoded string, or `nil` if decoding fails.
	private func decode(_ encoded: String) -> String? {
		Configuration.shared.secretCoder.decode(encoded)
	}
}
