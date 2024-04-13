import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    private let viewModel = SearchViewModel()
    private var searchHistoryTableViewHeightConstraint: NSLayoutConstraint?
    private var searchCount = 0


    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Введите запрос"
        return searchBar
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var searchHistoryTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private var albumsCollection: ReuseCollectionView?
    private var songsCollection: ReuseCollectionView?
    private var audiobooksCollection: ReuseCollectionView?
    private var moviesCollection: ReuseCollectionView?
    private var tvEpisodesCollection: ReuseCollectionView?
    private var ebooksCollection: ReuseCollectionView?
    private var podcastsCollection: ReuseCollectionView?


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideSearchHistoryOnTap))
//         view.addGestureRecognizer(tapGestureRecognizer)
    }


    private func searchiTunes(query: String) {
        viewModel.albums.removeAll()
        viewModel.songs.removeAll()
        viewModel.audiobooks.removeAll()
        viewModel.ebooks.removeAll()
        viewModel.movies.removeAll()
        viewModel.podcasts.removeAll()
        viewModel.tvEpisodes.removeAll()

        let entityTypes: [EntityType] = [.album, .song, .audiobook, .ebook, .movie, .podcast, .tvEpisode]
        let dispatchGroup = DispatchGroup()

        for entityType in entityTypes {
            dispatchGroup.enter()
            viewModel.searchDataArray(query: query, entity: entityType) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print("Ошибка при поиске \(entityType.rawValue): \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.createCollections()
                self.setupStackView()
            }
        }
    }
}

private extension SearchViewController {
    
    func setupViews() {
        setupSearchBar()
        setupSearchHistoryTableView()
        setupScrollView()
        setupStackView()
        hideSearchHistory()
    }
    
    func setupSearchHistoryTableView() {
        view.addSubview(searchHistoryTableView)
        searchHistoryTableViewHeightConstraint = searchHistoryTableView.heightAnchor.constraint(equalToConstant: 0)
        searchHistoryTableViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            searchHistoryTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor,constant: -2),
            searchHistoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48),
            searchHistoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48),
            searchHistoryTableViewHeightConstraint!,
        ])
        
        searchHistoryTableView.delegate = self
        searchHistoryTableView.dataSource = self
    }

    func setupScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func createCollections() {
        
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        self.albumsCollection = ReuseCollectionView(frame: .zero, data: self.viewModel.albums, title: "Albums")
        self.songsCollection = ReuseCollectionView(frame: .zero, data: self.viewModel.songs, title: "Tracks")
        self.audiobooksCollection = ReuseCollectionView(frame: .zero, data: self.viewModel.audiobooks, title: "AudioBooks")
        self.ebooksCollection = ReuseCollectionView(frame: .zero, data: self.viewModel.ebooks, title: "Ebooks")
        self.moviesCollection = ReuseCollectionView(frame: .zero, data: self.viewModel.movies, title: "Movie")
        self.podcastsCollection = ReuseCollectionView(frame: .zero, data: self.viewModel.podcasts, title: "Podcasts")
        self.tvEpisodesCollection = ReuseCollectionView(frame: .zero, data: self.viewModel.tvEpisodes, title: "Episodes")
        songsCollection?.collectionViewDelegate = self
        albumsCollection?.collectionViewDelegate = self
        audiobooksCollection?.collectionViewDelegate = self
        ebooksCollection?.collectionViewDelegate = self
        moviesCollection?.collectionViewDelegate = self
        podcastsCollection?.collectionViewDelegate = self
        tvEpisodesCollection?.collectionViewDelegate = self
    }

    func setupStackView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.backgroundColor = .black
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let collectionHeight: CGFloat = 240


        if let songsCollection = songsCollection, !viewModel.songs.isEmpty {
            stackView.addArrangedSubview(songsCollection)
            songsCollection.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        }
        if let albumsCollection = albumsCollection, !viewModel.albums.isEmpty {
            stackView.addArrangedSubview(albumsCollection)
            albumsCollection.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        }
        if let moviesCollection = moviesCollection, !viewModel.movies.isEmpty {
            stackView.addArrangedSubview(moviesCollection)
            moviesCollection.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        }
        if let audiobooksCollection = audiobooksCollection, !viewModel.audiobooks.isEmpty {
            stackView.addArrangedSubview(audiobooksCollection)
            audiobooksCollection.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        }

        if let ebooksCollection = ebooksCollection, !viewModel.ebooks.isEmpty {
            stackView.addArrangedSubview(ebooksCollection)
            ebooksCollection.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        }

        if let podcastsCollection = podcastsCollection, !viewModel.podcasts.isEmpty{
            stackView.addArrangedSubview(podcastsCollection)
            podcastsCollection.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        }
        if let tvEpisodesCollection = tvEpisodesCollection, !viewModel.tvEpisodes.isEmpty {
            stackView.addArrangedSubview(tvEpisodesCollection)
            tvEpisodesCollection.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        }
        
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
    }

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SearchHistoryCell")
        cell.textLabel?.text = viewModel.searchHistory[indexPath.row]
        cell.backgroundColor = .lightGray
        cell.textLabel?.textColor = .black
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }




    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedQuery = viewModel.searchHistory[indexPath.row]
            searchBar.text = selectedQuery
            searchBarSearchButtonClicked(searchBar)
        }
}

extension SearchViewController {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
           showSearchHistory()
       }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        let lowercaseQuery = query.lowercased()
        let lowercaseSearchHistory = viewModel.searchHistory.map { $0.lowercased() }
        if !lowercaseSearchHistory.contains(lowercaseQuery) {
            increaseSearchHistoryHeight()
        }
        searchiTunes(query: query)
        addSearchHistory(query)
        searchBar.resignFirstResponder()
        hideSearchHistory()
    }
    func increaseSearchHistoryHeight() {
        if searchCount < 5 {
            searchCount += 1
            let newHeight = CGFloat(searchCount) * 30
            searchHistoryTableViewHeightConstraint?.constant = newHeight
        }
    }
}

extension SearchViewController: ReuseCollectionViewDelegate {
    func didSelectItem(_ item: Any) {
        if let itemData = item as? ItemData {
            let detailVC = DetailViewController()
            detailVC.wrapperType = itemData.wrapperType
            detailVC.itemName = itemData.name
            detailVC.itemImage = itemData.artworkUrl100
            detailVC.itemArtistName = itemData.artistName
            detailVC.country = itemData.country
            detailVC.primaryGenreName = itemData.primaryGenreName
            detailVC.releaseDate = itemData.releaseDate
            detailVC.trackViewUrl = itemData.trackViewUrl
            detailVC.artistViewUrl = itemData.artistViewUrl
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension SearchViewController {
    func showSearchHistory() {
        searchHistoryTableView.isHidden = false
        view.bringSubviewToFront(searchHistoryTableView)
    }

    func hideSearchHistory() {
        searchHistoryTableView.isHidden = true
    }
    func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 40)
        ])

        searchBar.delegate = self
    }
    func addSearchHistory(_ query: String) {
        let lowercaseQuery = query.lowercased()
        let lowercaseSearchHistory = viewModel.searchHistory.map { $0.lowercased() }

        if let index = lowercaseSearchHistory.firstIndex(of: lowercaseQuery) {
            viewModel.searchHistory.remove(at: index)
        }

        viewModel.searchHistory.insert(query, at: 0)

        if viewModel.searchHistory.count > 5 {
            viewModel.searchHistory.removeLast()
        }
        searchHistoryTableView.reloadData()
    }

}
