//
//  AddListController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 14.05.2021.
//
import SwiftUI
import UIKit

class AddEditListController: BaseAddController {
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView(image: UIImage(selectedIcon, at: 50, centeredIn: .init(width: 100, height: 100)))
        iv.tintColor = .white
        iv.preferredSymbolConfiguration = .init(scale: .small)
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 50
        iv.sizeThatFits(.init(width: 100, height: 100))
        iv.backgroundColor = selectedColor
        iv.layer.shadowRadius = 6
        iv.layer.shadowOpacity = 0.5
        iv.layer.shadowColor = selectedColor.cgColor
        iv.layer.shouldRasterize = true
        return iv
    }()
    
    let textField: PaddedTextField = {
        let tf = PaddedTextField()
        tf.backgroundColor = .systemGray5
        tf.clearButtonMode = .whileEditing
        tf.layer.cornerRadius = 12
        tf.textColor = .systemBlue
        tf.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        tf.textAlignment = .center
        tf.textInsets = .init(top: 10, left: 40, bottom: 10, right: 40)
        tf.font = UIFontMetrics.default.scaledFont(for: .boldSystemFont(ofSize: 22))
        tf.constrainHeight(constant: 52)
        return tf
    }()
    
    var list: List? {
        didSet {
            guard let list = list else { return }
            textField.text = list.name
            selectedIcon = list.icon
            selectedColor = list.color
        }
    }
    
    @objc private func textChanged(sender: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = sender.hasText
    }
    
    enum Section {
        case color, icon
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    var collectionView: UICollectionView!
    
    var selectedColor: UIColor = .systemBlue {
        didSet{
            imageView.backgroundColor = selectedColor
            imageView.layer.shadowColor = selectedColor.cgColor
            textField.textColor = selectedColor
        }
    }
    var selectedIcon: String = "list.bullet" {
        didSet{
            imageView.image = UIImage(selectedIcon, at: 50, centeredIn: .init(width: 100, height: 100))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = list?.name == nil ? "New List" : "Name & Appearance"
        setupViews()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem?.isEnabled = list != nil
        selectColorFromCollectionView()
    }
    
    @objc override func doneTapped() {
        if let list = list {
            list.name = textField.text ?? ""
            list.color = selectedColor
            list.icon = selectedIcon
            CoreDataManager.shared.saveContext() { _ in
                NotificationCenter.default.post(name: .updateList, object: nil)
            }
        } else {
            CoreDataManager.shared.createList(color: selectedColor, icon: selectedIcon, name: textField.text ?? "", date: Date())
        }
        super.doneTapped()
    }
    
    fileprivate func selectColorFromCollectionView() {
        if let selectedItem = snapshot.itemIdentifiers(inSection: .color).first(where: { $0.color == selectedColor }) {
            let index: Int = Item.colors.distance(from: Item.colors.startIndex, to: Item.colors.firstIndex(of: selectedItem) ?? 4)
            collectionView.selectItem(at: [0, index], animated: true, scrollPosition: .bottom)
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 20, bottom: 0, trailing: 20)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private struct Item: Hashable {
        var image: UIImage?
        var color: UIColor?
        var imageString: String?
        
        init(imageName: String) {
            self.image = UIImage(systemName: imageName)
            self.imageString = imageName
        }
        
        init(color: UIColor) {
            self.color = color
        }
        private let identifier = UUID()
        static let colors = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple, .systemTeal, .systemPink, .systemIndigo, .systemGray, .magenta, .brown].map { Item(color: $0) }
        
        static let all = [
            "face.smiling", "trash", "folder", "paperplane", "book", "tag", "camera", "pin",
            "lock.shield", "cube.box", "gift", "eyeglasses", "lightbulb"
        ].map { Item(imageName: $0) }
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CustomConfigurationCell, Item> { (cell, indexPath, item) in
            cell.listColor = item.color
            cell.image = item.image
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

       
        snapshot.appendSections([.color, .icon])
        snapshot.appendItems(Item.colors, toSection: .color)
        snapshot.appendItems(Item.all, toSection: .icon)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupViews() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        view.addSubview(imageView)
        imageView.centerXInSuperview()
        imageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 20, left: 0, bottom: 0, right: 0), size: .init(width: 100, height: 100))
        
        view.addSubview(textField)
        textField.becomeFirstResponder()
        textField.anchor(top: imageView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 20, bottom: 0, right: 20))
        
        view.addSubview(collectionView)
        collectionView.anchor(top: textField.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 20, left: 0, bottom: 0, right: 0))
    }
}

extension AddEditListController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        if let color = item?.color {
            selectedColor = color
        } else if let imageString = item?.imageString {
            selectedIcon = imageString
        }
    }
}

struct preview: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
//            AddListController()
            UINavigationController(rootViewController: AddEditListController())
        }
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
