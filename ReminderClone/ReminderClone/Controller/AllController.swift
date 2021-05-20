//
//  AllController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 18.05.2021.
//

import UIKit
import CoreData

class AllController: UITableViewController {
    
    private lazy var addReminderButton = createReminderButton(selector: #selector(addReminder))
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Reminder> = {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request = Reminder.createFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context,
                                             sectionNameKeyPath: "list", cacheName: nil)
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
        title = "All"
        navigationItem.largeTitleDisplayMode = .always
        let apperance = UINavigationBarAppearance()
        apperance.largeTitleTextAttributes = [.foregroundColor: UIColor.darkGray]
        navigationController?.navigationBar.standardAppearance = apperance
        
        setupToolbar()
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .systemGroupedBackground
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.register(ReminderCell.self, forCellReuseIdentifier: ReminderCell.reuseIdentifier)
        tableView.layoutMargins = .zero
        tableView.separatorInset = .init(top: 0, left: 44, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = false
    }
    
    private func setupToolbar() {
        addReminderButton.tintColor = .darkGray
        let toolBar = navigationController?.toolbar
        let toolbarApperance = UIToolbarAppearance()
        toolbarApperance.backgroundColor = .systemGroupedBackground
        toolbarApperance.shadowColor = .clear
        toolBar?.standardAppearance = toolbarApperance
        toolbarItems = [UIBarButtonItem(customView: addReminderButton), .flexibleSpace()]
    }
    
    @objc func addReminder() {
        let addReminderController = AddEditReminderController()
        present(UINavigationController(rootViewController: addReminderController), animated: true, completion: nil)
    }
}

// MARK: - TableView Methods

extension AllController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if fetchedResultsController.sections?.count == 0 {
            tableView.setEmptyMessage("No Reminders")
        } else {
            tableView.restore()
        }
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.reuseIdentifier, for: indexPath) as! ReminderCell
        let reminder = fetchedResultsController.sections?[indexPath.section].objects?[indexPath.row]
        cell.reminder = reminder as? Reminder
        cell.textView.isSelectable = false
        cell.textView.isEditable = false
        cell.layoutMargins = .zero
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Title"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            guard let list = (fetchedResultsController.sections?[section].objects?.first as? Reminder)?.list else { return }
            var content = UIListContentConfiguration.plainHeader()
            content.text = list.name
            content.textProperties.color = list.color
            headerView.contentConfiguration = content
            var bgConfig = UIBackgroundConfiguration.clear()
            bgConfig.backgroundColor = tableView.backgroundColor
            headerView.backgroundConfiguration = bgConfig
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let reminder = fetchedResultsController.object(at: indexPath)
        return reminder.title.heightWithConstrainedWidth(width: tableView.frame.width - 120, font: UIFont.systemFont(ofSize: 16)) + 28
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 2))
        v.backgroundColor = tableView.separatorColor
        return v
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (fetchedResultsController.sections?.count ?? 0) > 1 ? 2 : 0
    }
}

extension AllController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {

    }
}
