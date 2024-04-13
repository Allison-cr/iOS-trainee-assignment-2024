import Foundation

struct SearchResult: Codable {
    let results: [SearchItem]
}

struct SearchItem: Codable {
    let wrapperType: String?
    let artistName: String?
    let collectionName: String?
    let trackName: String?
    let previewUrl: URL?
    let artworkUrl100: URL?
    let releaseDate: String?
    let country: String?
    let primaryGenreName: String?
    let trackViewUrl: String?
    let artistViewUrl: String?
    let collectionViewUrl: String?
    let collectionArtistViewUrl: String?
}
