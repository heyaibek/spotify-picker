import Foundation

struct TokenStore {
	static let shared = TokenStore(userDefaultsKey: "spotify-picker")

	private let valueKey: String
	private let timeKey: String

	init(userDefaultsKey: String) {
		valueKey = userDefaultsKey
		timeKey = userDefaultsKey.appending("-expiration-time")
	}

	private var now: TimeInterval {
		Date().timeIntervalSince1970
	}

	var currentToken: String? {
		guard let token = securedCurrentToken else {
			return nil
		}
		return decode(token)
	}

	var securedCurrentToken: String? {
		let expires = UserDefaults.standard.double(forKey: timeKey)
		if expires < now {
			return nil
		}
		return UserDefaults.standard.string(forKey: valueKey)
	}

	func persist(token: String, expiresInSeconds: Int) {
		if expiresInSeconds > 0 {
			let expires = now + Double(expiresInSeconds)
			UserDefaults.standard.setValue(encode(token), forKey: valueKey)
			UserDefaults.standard.setValue(expires, forKey: timeKey)
		}
	}

	private func encode(_ string: String) -> String {
		Configuration.shared.secretCoder.encode(string)
	}

	private func decode(_ encoded: String) -> String? {
		Configuration.shared.secretCoder.decode(encoded)
	}
}
