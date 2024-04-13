import Foundation

struct ItemData: Codable {
    let wrapperType: String
    let name: String
    let artistName: String
    let artworkUrl100: URL
    let releaseDate: String
    let country: String
    let primaryGenreName: String
    let trackViewUrl: String
    let artistViewUrl: String
}
