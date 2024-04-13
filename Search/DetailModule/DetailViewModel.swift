class DetailViewModel {
    
    var artist: [ItemData] = []
    var genre: [ItemData] = []
    
    func searchGenreArtistArray(query: String, entityType: String, arrayType: String, completion: @escaping (Error?) -> Void) {
        LoadManager.shared.SearchData(query: query, entity: entityType) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let searchItems):
                let items = searchItems.compactMap { searchItem -> ItemData? in
                    return self.createItem(from: searchItem)
                }
                switch arrayType {
                case "artist":
                    self.artist = items
                case "genre":
                    self.genre = items
                default:
                    break
                }
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    private func createItem(from searchItem: SearchItem) -> ItemData? {
        guard let name = searchItem.collectionName,
              let wrapperType = searchItem.wrapperType,
              let artistName = searchItem.artistName,
              let artworkUrl = searchItem.artworkUrl100,
              let releaseDate = searchItem.releaseDate,
              let country = searchItem.country,
              let primaryGenreName = searchItem.primaryGenreName,
              let trackViewUrl = searchItem.trackViewUrl,
              let artistViewUrl = searchItem.artistViewUrl
        else {
            return nil
        }
        return ItemData(wrapperType: wrapperType, name: name, artistName: artistName, artworkUrl100: artworkUrl, releaseDate: releaseDate, country: country, primaryGenreName: primaryGenreName, trackViewUrl: trackViewUrl, artistViewUrl: artistViewUrl)
    }
}
