//
//  ViewController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 13.05.2021.
//

import UIKit
import CoreData
import SwiftUI

class HomeController: UIViewController {
    
    enum Section: Int, CaseIterable, CustomStringConvertible {
        case header, list
        
        var description: String {
            switch self {
            case .header: return "Reminders"
            case .list: return "Lists"
            }
        }
    }
    
    struct HeaderItem: Hashable {
        let title: String
        let icon: String
        let count: Int
        let color: UIColor
        private let identifier = UUID()
    }
    
    var collectionView: UICollectionView!
    var searchController: UISearchController!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    var diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
    var request: NSFetchRequest<List>!
    var fetchedListResultsController: NSFetchedResultsController<List>!
    
    var reminderRequest: NSFetchRequest<Reminder>!
    var fetchedReminderResultsController: NSFetchedResultsController<Reminder>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isToolbarHidden = false
        setupToolbar()
        configureCollectionView()
        configureDataSource()
        coreDataRequest()
        
        let resultsController = ResultsController()
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
        
//        NotificationCenter.default.addObserver(self, selector: #selector(updateSnapshot(animated:)), name: .createList, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(updateSnapshot(animated:)), name: .createReminder, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    var addReminderButton: UIBarButtonItem!
    
    fileprivate func setupToolbar() {
        let toolBar = navigationController?.toolbar
        let toolbarApperance = UIToolbarAppearance()
        toolbarApperance.backgroundColor = .systemGroupedBackground
        toolbarApperance.shadowColor = .clear
        toolBar?.standardAppearance = toolbarApperance
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: config), for: .normal)
        button.titleLabel?.font = UIFontMetrics.default.scaledFont(for: .boldSystemFont(ofSize: 18))
        button.setTitle("  New Reminder", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(addReminder), for: .touchUpInside)
        addReminderButton = UIBarButtonItem(customView: button)
        toolbarItems = [
            addReminderButton,
            .flexibleSpace(),
            UIBarButtonItem(title: "Add List", style: .plain, target: self, action: #selector(addList))
        ]
    }
    
    @objc func addReminder() {
        print(#function)
        let addReminderController = AddReminderController()
        addReminderController.lists = dataSource.snapshot().itemIdentifiers(inSection: .list).map({ list in
            let list = list as! List
            return PickerItem(name: list.name, objectId: list.objectID, type: .list)
        }).reversed()
        present(UINavigationController(rootViewController: addReminderController), animated: true, completion: nil)
    }
    
    @objc func addList() {
        print(#function)
        let addListController = UINavigationController(rootViewController: AddListController())
        present(addListController, animated: true, completion: nil)
    }

    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            let section: NSCollectionLayoutSection
            if sectionKind == .header {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
                
            } else if sectionKind == .list {
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.trailingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
                    guard let self = self else { return nil }
                    guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
                    return self.leadingSwipeActionConfigurationForListCellItem(item as! List)
                }
                section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func accessoriesForListCellItem(_ list: List) -> [UICellAccessory] {
        var accessories = [UICellAccessory.disclosureIndicator()]
        let countLabel = UILabel()
        accessories.append(.customView(configuration: .init(customView: countLabel, placement: .trailing())))
        return accessories
    }
    
    func leadingSwipeActionConfigurationForListCellItem(_ item: List) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) {
            [weak self] (_, _, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            
            CoreDataManager.shared.persistentContainer.viewContext.delete(item)
            if CoreDataManager.shared.persistentContainer.viewContext.hasChanges {
                do {
                    try CoreDataManager.shared.persistentContainer.viewContext.save()
                    self.updateSnapshot(animated: false)
                } catch {
                    print("An error occured while saving: \(error)")
                }
            }
            
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func createGridCellRegistration() -> UICollectionView.CellRegistration<HomeHeaderCell, HeaderItem> {
        return UICollectionView.CellRegistration<HomeHeaderCell, HeaderItem> { (cell, indexPath, header) in
//            var content = UIListContentConfiguration.cell()
//            content.image = UIImage(systemName: header.icon)
//            content.text = "\(header.count)"
//            content.secondaryText = "\(header.title)"
//            content.imageProperties.tintColor = .label
////            content.textProperties.font = .boldSystemFont(ofSize: 18)
//            content.textProperties.alignment = .natural
//            content.directionalLayoutMargins = .zero
////            content.imageToTextPadding = 100
//            content.prefersSideBySideTextAndSecondaryText = true
//            content.textToSecondaryTextVerticalPadding = 10
//            content.imageProperties.maximumSize = .init(width: 20, height: 20)
//            cell.contentConfiguration = content

            cell.countLabel.text = "\(header.count)"
            cell.titleLabel.text = "\(header.title)"
            cell.iconView.image = UIImage(systemName: header.icon)
            cell.imageBackground.backgroundColor = header.color
            var background = UIBackgroundConfiguration.listGroupedCell()
            background.cornerRadius = 8
            cell.backgroundConfiguration = background
        }
    }
    
//    func createGridCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, HeaderItem> {
//        return UICollectionView.CellRegistration<UICollectionViewCell, HeaderItem> { (cell, indexPath, header) in
////            var content = UIListContentConfiguration.cell()
////            var content = UIListContentConfiguration.subtitleCell()
////            content.image = UIImage(systemName: header.icon)
////            content.text = "\(header.count)"
////            content.secondaryText = "\(header.title)"
////            content.imageProperties.tintColor = .label
//////            content.textProperties.font = .boldSystemFont(ofSize: 18)
////            content.textProperties.alignment = .natural
////            content.directionalLayoutMargins = .zero
//////            content.imageToTextPadding = 100
////            content.prefersSideBySideTextAndSecondaryText = true
////            content.textToSecondaryTextVerticalPadding = 10
////            content.imageProperties.maximumSize = .init(width: 20, height: 20)
////            cell.contentConfiguration = content
//            var background = UIBackgroundConfiguration.listGroupedCell()
//            background.cornerRadius = 8
//            cell.backgroundConfiguration = background
//        }
//    }
    
    func createListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, List> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, List> { [weak self] (cell, indexPath, item) in
            guard let self = self else { return }
            var content = UIListContentConfiguration.valueCell()
            if let imageData = UIImage(item.icon, at: (16 * 3 / 2), centeredIn: .init(width: 16 * 3, height: 16 * 3))?.pngData() {
                let newImage = UIImage(data: imageData, scale: 3)
                content.image = newImage?.withRoundedCorners(radius: 8, color: item.color)
            }
            content.text = item.name
            content.imageProperties.tintColor = item.color
            content.secondaryText = "\(item.reminders?.count ?? 0)"
            cell.contentConfiguration = content
            cell.backgroundColor = item.color
            cell.accessories = self.accessoriesForListCellItem(item)
        }
    }
    
    func configureDataSource() {
        let gridCellRegistration = createGridCellRegistration()
        let listCellRegistration = createListCellRegistration()

        dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }
            switch section {
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: gridCellRegistration, for: indexPath, item: item as? HeaderItem)
            case .list:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: item as? List)
            }
        }
    }
    
    fileprivate func coreDataRequest() {
        request = List.createFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        fetchedListResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedListResultsController.delegate = self
        
        reminderRequest = Reminder.createFetchRequest()
        reminderRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchedReminderResultsController = NSFetchedResultsController(fetchRequest: reminderRequest, managedObjectContext: CoreDataManager.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedReminderResultsController.delegate = self
        
        do {
            try fetchedListResultsController.performFetch()
            try fetchedReminderResultsController.performFetch()
            updateSnapshot(animated: false)
        } catch {
            print(error)
        }
    }
    
    @objc private func updateSnapshot(animated: Bool = true) {
        
        let flagsCount = fetchedReminderResultsController.fetchedObjects?.filter({ $0.flag })
        let allCount = fetchedReminderResultsController.fetchedObjects
                
        let headers = [
            HeaderItem(title: "All", icon: "tray.fill", count: allCount?.count ?? 0, color: .darkGray),
            HeaderItem(title: "Flagged", icon: "flag.fill", count: flagsCount?.count ?? 0, color: .systemOrange),
        ]

        addReminderButton.isEnabled = !(fetchedListResultsController.fetchedObjects?.isEmpty ?? true)
        let sections = Section.allCases
        diffableDataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        diffableDataSourceSnapshot.appendSections(sections)
        
        diffableDataSourceSnapshot.appendItems(headers, toSection: .header)
        diffableDataSourceSnapshot.appendItems(fetchedListResultsController.fetchedObjects ?? [], toSection: .list)
//        diffableDataSourceSnapshot.appendItems(fetchedResultsController.fetchedObjects ?? [], toSection: .list)
//        dataSource?.apply(diffableDataSourceSnapshot, animatingDifferences: animated)
        dataSource.apply(diffableDataSourceSnapshot, animatingDifferences: animated)
    }
}

extension HomeController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        if indexPath.section == 1 {
            if let list = dataSource.itemIdentifier(for: indexPath) as? List {
                let listController = ListController(list: list)
                navigationController?.pushViewController(listController, animated: true)
            }
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    

    
//        let detailViewController = EmojiDetailViewController(with: emoji)
//        self.navigationController?.pushViewController(detailViewController, animated: true)
}

extension HomeController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}

extension HomeController: UISearchControllerDelegate, UISearchBarDelegate  {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
}


struct PreviewHome: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            UINavigationController(rootViewController: HomeController())
        }
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
