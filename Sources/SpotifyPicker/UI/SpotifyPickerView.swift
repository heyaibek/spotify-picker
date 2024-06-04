import SwiftUI

public struct SpotifyPickerView: View {
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

	public init(pickerItem: Binding<PickerItem?>) {
		_pickerItem = pickerItem
	}

	public init(pickerItem: Binding<PickerItem?>, search: String) {
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
		.searchable(text: $searchText)
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
