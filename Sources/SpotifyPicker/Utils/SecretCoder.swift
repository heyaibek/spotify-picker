import Foundation

public protocol SecretCoder {
	func encode(_ accessToken: String) -> String
	func decode(_ encoded: String) -> String?
}

struct Base64SecretCoder: SecretCoder {
	func encode(_ accessToken: String) -> String {
		Data(accessToken.utf8).base64EncodedString()
	}

	func decode(_ encoded: String) -> String? {
		guard let data = Data(base64Encoded: encoded) else {
			return nil
		}
		return String(data: data, encoding: .utf8)
	}
}
