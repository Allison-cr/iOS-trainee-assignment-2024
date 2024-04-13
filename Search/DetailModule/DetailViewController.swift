import UIKit

class DetailViewController: UIViewController {
    var itemName: String?
    var itemImage: URL?
    var itemArtistName: String?
    var releaseDate: String?
    var country: String?
    var primaryGenreName: String?
    var trackViewUrl: String?
    var artistViewUrl: String?
    var wrapperType: String?
    
    private var ArtistCollection: ReuseCollectionView?
    private var GengreCollection: ReuseCollectionView?
    
    private let viewModel = DetailViewModel()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.numberOfLines = 2
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.numberOfLines = 2
        label.textColor = .gray
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .gray
        return label
    }()
    
    private let primaryGenreNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .gray
        return label
    }()
    
    private let countryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .gray
        return label
    }()
    
    private let artistButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("iTunes Store", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.tintColor = .white
        button.addTarget(self, action: #selector(openiTrackTunesStore), for: .touchUpInside)
        return button
    } ()
    
    private let trackViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Artist", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 24)
        button.tintColor = .white
        button.addTarget(self, action: #selector(openArtistiTunesStore), for: .touchUpInside)
        return button
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        title = wrapperType
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupViews() {
        setupScrollView()
        setupImageView()
        setupNameLabel()
        setupArtistLabel()
        setupReleaseDateLabel()
        setupPrimaryGenreNameLabel()
        setupCountryLabel()
        setupiTunesButton()
        setupArtistButton()
        searchiTunes()
    }
    
    private func searchiTunes() {
        viewModel.artist.removeAll()
        viewModel.genre.removeAll()
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        viewModel.searchGenreArtistArray(query: itemArtistName ?? "", entityType: "", arrayType: "artist") { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Ошибка при поиске автора: \(error.localizedDescription)")
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        viewModel.searchGenreArtistArray(query: primaryGenreName ?? "", entityType: "", arrayType: "genre") { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Ошибка при поиске жанра: \(error.localizedDescription)")
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.createCollections()
                self.setupStackView()
            }
        }
    }
    
    private func setupiTunesButton() {
        scrollView.addSubview(artistButton)
        artistButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            artistButton.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: 16),
            artistButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            artistButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupArtistButton() {
        scrollView.addSubview(trackViewButton)
        trackViewButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackViewButton.topAnchor.constraint(equalTo: artistButton.bottomAnchor, constant: 16),
            trackViewButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            trackViewButton.heightAnchor.constraint(equalToConstant: 32)
            
        ])
    }
    
    @objc private func openiTrackTunesStore() {
        guard let url = URL(string: trackViewUrl ?? "") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    @objc private func openArtistiTunesStore() {
        guard let url = URL(string: artistViewUrl ?? "") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func createCollections() {
        self.ArtistCollection = ReuseCollectionView(frame: .zero, data: self.viewModel.artist, title: "More \(itemArtistName ?? "")")
        self.GengreCollection = ReuseCollectionView(frame: .zero, data: self.viewModel.genre, title: "More \(primaryGenreName ?? "")")
        ArtistCollection?.collectionViewDelegate = self
        GengreCollection?.collectionViewDelegate = self
    }
    
    private func setupStackView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.backgroundColor = .black
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let collectionHeight: CGFloat = 240
        
        if let ArtistCollection = ArtistCollection, !viewModel.artist.isEmpty {
            stackView.addArrangedSubview(ArtistCollection)
            ArtistCollection.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
            
        }
        if let GengreCollection = GengreCollection, !viewModel.genre.isEmpty {
            stackView.addArrangedSubview(GengreCollection)
            GengreCollection.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
            
        }
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: trackViewButton.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    func setupImageView() {
        scrollView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 3)
        ])
        if let imageURL = itemImage {
            DispatchQueue.global().async { [weak self] in
                if let imageData = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async {
                        self?.imageView.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    func setupNameLabel() {
        scrollView.addSubview(nameLabel)
        nameLabel.text = itemName
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32),
            nameLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 16),
        ])
    }
    func setupArtistLabel() {
        scrollView.addSubview(artistLabel)
        artistLabel.text = itemArtistName
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            artistLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            artistLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            artistLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 16),
        ])
    }
    func setupReleaseDateLabel() {
        scrollView.addSubview(releaseDateLabel)
        releaseDateLabel.text = formatDateString(releaseDate ?? "")
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            releaseDateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32),
            releaseDateLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
        ])
    }
    func setupPrimaryGenreNameLabel() {
        scrollView.addSubview(primaryGenreNameLabel)
        primaryGenreNameLabel.text = "Genre: \(primaryGenreName ?? "")"
        primaryGenreNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            primaryGenreNameLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 16),
            primaryGenreNameLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
        ])
    }
    func setupCountryLabel() {
        scrollView.addSubview(countryLabel)
        countryLabel.text = "Country: \(country ?? "")"
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countryLabel.topAnchor.constraint(equalTo: primaryGenreNameLabel.bottomAnchor, constant: 16),
            countryLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            countryLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 16),
        ])
    }
}
extension DetailViewController: ReuseCollectionViewDelegate {
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
