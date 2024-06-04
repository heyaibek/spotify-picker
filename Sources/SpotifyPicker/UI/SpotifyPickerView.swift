import SwiftUI

/// `SpotifyPickerView` is a SwiftUI view designed to allow users to search for and select music tracks from Spotify.
public struct SpotifyPickerView: View {
	/// Represents the different states the view can be in during the search and selection process.
	enum ViewState {
		case empty
		case invalidating
		case fetching
		case result([Track])
		case error(Error)
	}

	@Environment(\.dismiss) private var dismiss

	@StateObject private var tokenManager = TokenManager()
	@StateObject private var searchManager = SearchManager()

	@Binding private var pickerItem: PickerItem?

	@State private var searchText = ""
	@State private var viewState = ViewState.empty
	@State private var selectedTrack: Track? = nil

	/// Initializes a `SpotifyPickerView` with the specified configuration and picker item binding.
	/// - Parameters:
	///   - configuration: Configuration includes details such as the client ID, client secret, and secret coder required for interacting with the Spotify API.
	///   - pickerItem: A binding variable to track the selected item.
	public init(configuration: SpotifyPickerConfiguration, pickerItem: Binding<PickerItem?>) {
		Configuration.shared = configuration
		_pickerItem = pickerItem
	}

	/// Initializes a `SpotifyPickerView` with the specified configuration, picker item binding, and initial search query.
	/// - Parameters:
	///   - configuration: Configuration includes details such as the client ID, client secret, and secret coder required for interacting with the Spotify API.
	///   - pickerItem: A binding variable to track the selected item.
	///   - search: Initial search query
	public init(configuration: SpotifyPickerConfiguration, pickerItem: Binding<PickerItem?>, search: String) {
		Configuration.shared = configuration
		_pickerItem = pickerItem
		_searchText = State(initialValue: search)
	}

	public var body: some View {
		NavigationView {
			VStack {
				switch viewState {
				case .empty:
					NoContentView(
						"No Results",
						icon: .magnifyingglass,
						message: "Use the search field above to find your music."
					)
				case .invalidating:
					ProgressView("Invalidating...")
						.progressViewStyle(.circular)
				case .fetching:
					ProgressView("Fetching...")
						.progressViewStyle(.circular)
				case let .error(error):
					NoContentView(
						"Something went wrong",
						icon: .exclamationmarkTriangle,
						message: error.localizedDescription
					)
				case let .result(tracks):
					List {
						Section {
							ForEach(tracks, id: \.id) { track in
								TrackView(track) {
									selectedTrack = track
								}
							}
						} footer: {
							Text("Displaying the first \(tracks.count) tracks that match your search query. Tracks without a preview option are disabled.")
						}
					}
				}
			}
			.navigationBarTitle("Spotify")
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Cancel") {
						dismiss()
					}
				}
			}
			.disabled(tokenManager.isInvalidating || searchManager.isFetching)
		}
		.navigationViewStyle(.stack)
		.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
		.onSubmit(of: .search) {
			Task {
				await fetch()
			}
		}
		.onAppear {
			Task {
				if TokenStore.shared.currentToken == nil {
					await invalidateToken()
				}
				if !searchText.isEmpty {
					await fetch()
				}
			}
		}
		.sheet(item: $selectedTrack) { track in
			DownloaderView(track: track) { downloadedURL in
				let item = PickerItem(track: track, localPreviewURL: downloadedURL)

				selectedTrack = nil
				pickerItem = item
				dismiss()
			}
		}
	}

	private func invalidateToken() async {
		viewState = .invalidating
		do {
			try await tokenManager.invalidateToken()
			viewState = .empty
		} catch {
			viewState = .error(error)
		}
	}

	private func fetch() async {
		viewState = .fetching
		do {
			viewState = try await .result(searchManager.fetchTracks(query: searchText))
		} catch {
			viewState = .error(error)
		}
	}
}
