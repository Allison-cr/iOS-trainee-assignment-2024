import UIKit

protocol ReuseCollectionViewDelegate: AnyObject {
    func didSelectItem(_ item: Any)
}

class ReuseCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    weak var collectionViewDelegate: ReuseCollectionViewDelegate?

    private var collectionView: UICollectionView!
    private var data: [Any] = []
    private var titleLabel: UILabel!

    
    init(frame: CGRect, data: [Any], title: String) {
        super.init(frame: frame)
        self.data = data
        setupCollectionView(with: title)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    private func setupCollectionView(with title: String) {

        titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Helvetica-Bold", size: 24)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let screenSize = UIScreen.main.bounds.size
        layout.itemSize = CGSize(width: screenSize.width / 3, height: (screenSize.height - 100) / 4)
        layout.minimumLineSpacing = 30
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: "ItemCell")
        collectionView.dataSource = self
        collectionView.delegate = self 
        collectionView.showsHorizontalScrollIndicator = false
        
        addSubview(titleLabel)
        addSubview(collectionView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    func configure(with data: [Any]) {
        self.data = data
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        if let item = data[indexPath.item] as? ItemData {
            cell.configure(with: item)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = data[indexPath.item]
        collectionViewDelegate?.didSelectItem(selectedItem)
    }
}
