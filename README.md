# Spotify Picker for iOS

[![SPM Compatible](https://img.shields.io/badge/swiftpm-compatible-brightgreen.svg?style=flat-square)](https://github.com/apple/swift-package-manager)
[![License](https://img.shields.io/github/license/heyaibek/spotify-picker-ios.svg?style=flat-square)](https://github.com/heyaibek/spotify-picker-ios)

SpotifyPicker is a SwiftUI component that allows to search and download music previews from Spotify API with just a few lines of code.

![Spotify Picker for iOS preview](/Images/spotify-picker-preview.png "Spotify Picker for iOS")

## Navigate

- [Description](#description)
- [Requirements](#requirements)
- [Installation](#installation)
	- [Swift Package Manager](#swift-package-manager)
- [Usage](#usage)
	- [Configuration](#configuration)
	- [Presenting](#presenting)
- [Contribution](#contribution)
- [Apps Using](#apps-using)
- [License](#license)

## Description

SpotifyPicker is a SwiftUI component. You present it to offer your users to search and download music previews from Spotify API. Once they have selected a track, the picker downloads the music preview and returns `PickerItem` object that you can use in your app.

## Requirements

- iOS 15+
- Xcode 15.1+
- Swift 5.3+
- [Client ID and Client Secret for Spotify API](https://developer.spotify.com/documentation/web-api/tutorials/client-credentials-flow)

## Installation

### Swift Package Manager

To integrate SpotifyPicker into your Xcode project using [Swift Package Manager](https://github.com/apple/swift-package-manager), open dependency manager through `File > Swift Packages > Add Package Dependency...` and insert repository URL:

`https://github.com/heyaibek/spotify-picker-ios.git`

To add dependency in your own package, just specify it in dependencies of your `Package.swift`:

```swift
.package(
  name: "SpotifyPicker",
  url: "https://github.com/heyaibek/spotify-picker-ios.git",
  .upToNextMajor(from: "<LATEST_VERSION>")
)
```

## Usage

### Configuration

The `SpotifyPicker` is configured with an instance of `SpotifyPickerConfiguration`:

```swift
SpotifyPickerConfiguration(clientId: String,
                           clientSecret: String,
                           secretCoder: SecretCoder)
```

| Property           | Type          | Optional/Required | Default               |
| ------------------ | ------------- | ----------------- | --------------------- |
| **`clientId`**     | _String_      | Required          | N/A                   |
| **`clientSecret`** | _String_      | Required          | N/A                   |
| **`secretCoder`**  | _SecretCoder_ | Optional          | `Base64SecretCoder()` |

SpotifyPicker uses the [Client Credentials Flow](https://developer.spotify.com/documentation/web-api/tutorials/client-credentials-flow) to obtain an access token for futher API calls. When the authorization request succeeds, Spotify API returns an access token with a specified expiration time. SpotifyPicker then stores the access token within `UserDefaults.standard` using `SecretCoder` utility in order to hide the raw access token and to provide some kind of "security". By default the `Base64SecretCoder` is used to encode and decode the access token with Base64. However, you can provide your own implementation of `SecretCoder` protocol and pass it to the **configuration**.

### Presenting


```swift
import SpotifyPicker
import SwiftUI

struct SearchTerm: Identifiable {
	let id = UUID().uuidString
	let query: String
}

struct SpotifyPickerDemo: View {
	private let configuration: SpotifyPickerConfiguration

	@State private var searchTerm: SearchTerm? = nil
	@State private var pickerItem: PickerItem? = nil

	var body: some View {
		VStack(spacing: 20) {
			if let pickerItem {
				Text(pickerItem.track.artistNames)
				Text(pickerItem.track.name)
				Text(pickerItem.localPreviewURL.path)
			}
			Button("Open Picker") {
				searchTerm = SearchTerm(query: "")
			}
			Button("Open Picker With Search") {
				searchTerm = SearchTerm(query: "Dabeul")
			}
		}
		.padding()
		.sheet(item: $searchTerm) { term in
			SpotifyPickerView(
				configuration: SpotifyPickerConfiguration(
					clientId: "SPOTIFY_CLIENT_ID",
					clientSecret: "SPOTIFY_CLIENT_SECRET"
				),
				pickerItem: $pickerItem,
				search: term.query
			)
		}
	}
}
```

## Contribution

I'm excited to invite you to contribute to **SpotifyPicker**, my open-source SwiftUI package designed to enhance your development experience. You can help with contributions like:

* Add new features
* Fix bugs
* Improve documentation
* Review code
* Create examples/tutorials
* etc.

## Apps Using

<p float="left">
    <a href="https://apps.apple.com/app/id1528056717">
		<img src="/Images/Apps/id1528056717.png" height="65" alt="Vibely - Music Visualizer" />
	</a>
</p>

If you use SpotifyPicker, add your app via Pull Request.

## License

MIT License

Copyright (c) 2024 Aibek Mazhitov

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
