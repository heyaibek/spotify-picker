import Foundation

extension Int {
	var asSeconds: Double {
		Double(self) / 1000
	}
}

// https://stackoverflow.com/a/30772571/10309700
extension TimeInterval {
	var millisecond: Int {
		Int((self * 1000).truncatingRemainder(dividingBy: 1000))
	}

	var second: Int {
		Int(truncatingRemainder(dividingBy: 60))
	}

	var minute: Int {
		Int((self / 60).truncatingRemainder(dividingBy: 60))
	}

	var hour: Int {
		Int((self / 3600).truncatingRemainder(dividingBy: 3600))
	}

	var ms: String {
		String(format: "%02d:%02d", minute, second)
	}

	var mss: String {
		String(format: "%02d:%02d.%03d", minute, second, millisecond)
	}

	var hmss: String {
		String(format: "%02d:%02d:%02d.%03d", hour, minute, second, millisecond)
	}
}
