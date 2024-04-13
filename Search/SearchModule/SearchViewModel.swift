//
//  SearchViewModel.swift
//  Search
//
//  Created by Alexander Suprun on 08.04.2024.
//

import Foundation


enum EntityType: String {
    case album
    case song
    case audiobook
    case movie
    case tvEpisode
    case ebook
    case podcast
}


class SearchViewModel {
    var albums: [ItemData] = []
    var songs: [ItemData] = []
    var audiobooks: [ItemData] = []
    var movies: [ItemData] = []
    var tvEpisodes: [ItemData] = []
    var ebooks: [ItemData] = []
    var podcasts: [ItemData] = []
    
    var artist: [ItemData] = []
    var genre: [ItemData] = []
    
    var searchHistory: [String] = []
    
    func searchDataArray(query: String, entity: EntityType, completion: @escaping (Error?) -> Void) {
        LoadManager.shared.SearchData(query: query, entity: entity.rawValue) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let searchItems):
                let items = searchItems.compactMap { searchItem -> ItemData? in
                    return self.createItem(from: searchItem, entityType: entity)
                }
                switch entity {
                case .album:
                    self.albums = items
                case .song:
                    self.songs = items
                case .audiobook:
                    self.audiobooks = items
                case .movie:
                    self.movies = items
                case .tvEpisode:
                    self.tvEpisodes = items
                case .ebook:
                    self.ebooks = items
                case .podcast:
                    self.podcasts = items
                }
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    private func createItem(from searchItem: SearchItem, entityType: EntityType) -> ItemData? {
        var itemName: String?
        var urlName: String?
        var artistUrlName: String?
        switch entityType {
        case .album:
            itemName = searchItem.collectionName
            urlName = searchItem.collectionViewUrl
            artistUrlName = searchItem.artistViewUrl
        case .song:
            itemName = searchItem.trackName
            urlName = searchItem.collectionViewUrl
            artistUrlName = searchItem.artistViewUrl
        case .audiobook:
            itemName = searchItem.collectionName
            urlName = searchItem.collectionViewUrl
            artistUrlName = searchItem.artistViewUrl
        case .movie:
            itemName = searchItem.collectionName
            urlName = searchItem.collectionViewUrl
            artistUrlName = searchItem.collectionArtistViewUrl
        case .tvEpisode:
            itemName = searchItem.collectionName
            urlName = searchItem.collectionViewUrl
            artistUrlName = searchItem.artistViewUrl
        case .ebook:
            itemName = searchItem.collectionName
            urlName = searchItem.collectionViewUrl
            artistUrlName = searchItem.artistViewUrl
        case .podcast:
            itemName = searchItem.collectionName
            urlName = searchItem.collectionViewUrl
            artistUrlName = searchItem.artistViewUrl
        }
        guard let name = itemName,
              let wrapperType = searchItem.wrapperType,
              let artistName = searchItem.artistName,
              let artworkUrl = searchItem.artworkUrl100,
              let releaseDate = searchItem.releaseDate,
              let country = searchItem.country,
              let primaryGenreName = searchItem.primaryGenreName,
              let trackViewUrl = urlName,
              let artistViewUrl = artistUrlName
        else {
            return nil
        }
        return ItemData(wrapperType: wrapperType, name: name, artistName: artistName, artworkUrl100: artworkUrl, releaseDate: releaseDate, country: country, primaryGenreName: primaryGenreName, trackViewUrl: trackViewUrl, artistViewUrl: artistViewUrl)
    }
}

