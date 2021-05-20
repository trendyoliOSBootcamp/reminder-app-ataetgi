//
//  FlagController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 18.05.2021.
//

import UIKit
import CoreData

class FlagController: UITableViewController {
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Reminder> = {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request = Reminder.createFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = NSPredicate(format: "flag == '1'")
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context,
                                             sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            debugPrint(error)
        }
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        title = "Flagged"
        navigationItem.largeTitleDisplayMode = .always
        let apperance = UINavigationBarAppearance()
        apperance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemOrange]
        navigationController?.navigationBar.standardAppearance = apperance
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .systemGroupedBackground
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.layoutMargins = .zero
        tableView.separatorInset = .init(top: 0, left: 44, bottom: 0, right: 0)
        tableView.register(ReminderCell.self, forCellReuseIdentifier: ReminderCell.reuseIdentifier)
    }
}

// MARK: - TableView Methods

extension FlagController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fetchedResultsController.fetchedObjects?.count == 0 {
            tableView.setEmptyMessage("No Reminders")
        } else {
            tableView.restore()
        }
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.reuseIdentifier, for: indexPath) as! ReminderCell
        let reminder = fetchedResultsController.sections?[indexPath.section].objects?[indexPath.row]
        cell.reminder = reminder as? Reminder
        cell.textView.isEditable = false
        cell.textView.isSelectable = false
        cell.layoutMargins = .zero
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let reminder = fetchedResultsController.object(at: indexPath)
        return reminder.title.heightWithConstrainedWidth(width: tableView.frame.width - 120, font: UIFont.systemFont(ofSize: 16)) + 28
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}


extension FlagController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {

    }
}
