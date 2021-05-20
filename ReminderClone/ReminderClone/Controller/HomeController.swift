//
//  ViewController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 13.05.2021.
//

import UIKit
import CoreData

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
        setupSearchController()
        setupToolbar()
        configureCollectionView()
        configureDataSource()
        coreDataRequest()

        NotificationCenter.default.addObserver(self, selector: #selector(updateSnapshot(animated:)), name: .updateList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSnapshot(animated:)), name: .updateReminder, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.toolbar.isHidden = false
    }
    
    lazy var addReminderButton = UIBarButtonItem(customView: createReminderButton(selector: #selector(addReminder)))
    
    private func setupSearchController() {
        let resultsController = ResultsController()
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupToolbar() {
        let toolBar = navigationController?.toolbar
        let toolbarApperance = UIToolbarAppearance()
        toolbarApperance.backgroundColor = .systemGroupedBackground
        toolbarApperance.shadowColor = .clear
        toolBar?.standardAppearance = toolbarApperance
        toolbarItems = [
            addReminderButton,
            .flexibleSpace(),
            UIBarButtonItem(title: "Add List", style: .plain, target: self, action: #selector(addList))
        ]
    }
    
    @objc func addReminder() {
        print(#function)
        let addReminderController = AddEditReminderController()
        present(UINavigationController(rootViewController: addReminderController), animated: true, completion: nil)
    }
    
    @objc func addList() {
        print(#function)
        let addListController = UINavigationController(rootViewController: AddEditListController())
        present(addListController, animated: true, completion: nil)
    }

    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleHeight]
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
                    self.updateSnapshot()
                    completion(true)
                } catch {
                    print("An error occured while saving: \(error)")
                    completion(false)
                }
            }
        }
        
        let infoAction = UIContextualAction(style: .normal, title: nil) {[weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }
            let addListController = AddEditListController()
            addListController.list = item
            self.present(UINavigationController(rootViewController: addListController), animated: true, completion: nil)
            
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        infoAction.image = UIImage(systemName: "info.circle.fill")
        infoAction.backgroundColor = .systemGray
        
        return UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
    }
    
    func createGridCellRegistration() -> UICollectionView.CellRegistration<HomeHeaderCell, HeaderItem> {
        return UICollectionView.CellRegistration<HomeHeaderCell, HeaderItem> { (cell, indexPath, header) in
            cell.countLabel.text = "\(header.count)"
            cell.titleLabel.text = "\(header.title)"
            cell.iconView.image = UIImage(systemName: header.icon)
            cell.imageBackground.backgroundColor = header.color
            var background = UIBackgroundConfiguration.listGroupedCell()
            background.cornerRadius = 8
            cell.backgroundConfiguration = background
        }
    }
    
    func createListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, List> {
        return UICollectionView.CellRegistration<UICollectionViewListCell, List> { [weak self] (cell, indexPath, item) in
            guard let self = self else { return }
            var content = UIListContentConfiguration.valueCell()
            if let imageData = UIImage(item.icon, at: (16 * 3 / 2), centeredIn: .init(width: 16 * 3, height: 16 * 3))?.pngData() {
                let newImage = UIImage(data: imageData, scale: 3)
                content.image = newImage?.withRoundedCorners(radius: 16, color: item.color)
            }
            content.text = item.name
            content.imageProperties.tintColor = item.color
            content.secondaryText = "\(item.reminders!.count.description)"
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
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

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
        } else {
            if indexPath.item == 0 {
                navigationController?.pushViewController(AllController(), animated: true)
            } else {
                navigationController?.pushViewController(FlagController(), animated: true)
            }
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension HomeController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
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
