//
//  AllController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 18.05.2021.
//

import UIKit
import CoreData
import SwiftUI

class AllController: UITableViewController {

    let cellId = "cellId"
    lazy var addReminderButton = createReminderButton(selector: #selector(addReminder))
    
    lazy var fetchedResultsController: NSFetchedResultsController<Reminder> = {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request = Reminder.createFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "list", cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            print(error)
        }
        return frc
    }()
    
    lazy var noReminderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .center
        label.text = "No Reminders"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = noReminderLabel
        tableView.backgroundColor = .systemGroupedBackground
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        let tview = UIView()
        tview.backgroundColor = .blue
        tableView.register(ReminderCell.self, forCellReuseIdentifier: cellId)
        tableView.layoutMargins = .zero
        tableView.separatorInset = .init(top: 0, left: 44, bottom: 0, right: 0)
        title = "All"
        navigationItem.largeTitleDisplayMode = .always
        let apperance = UINavigationBarAppearance()
        apperance.largeTitleTextAttributes = [.foregroundColor: UIColor.darkGray]
        navigationController?.navigationBar.standardAppearance = apperance
        
        setupToolbar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = false
    }
    
    fileprivate func setupToolbar() {
        addReminderButton.tintColor = .darkGray
        let toolBar = navigationController?.toolbar
        let toolbarApperance = UIToolbarAppearance()
        toolbarApperance.backgroundColor = .systemGroupedBackground
        toolbarApperance.shadowColor = .clear
        toolBar?.standardAppearance = toolbarApperance
        toolbarItems = [UIBarButtonItem(customView: addReminderButton), .flexibleSpace()]
    }
    
    @objc func addReminder() {
        print(#function)
        let addReminderController = AddEditReminderController()
        present(UINavigationController(rootViewController: addReminderController), animated: true, completion: nil)
    }
}

extension AllController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ReminderCell
        let reminder = fetchedResultsController.object(at: indexPath)
        cell.reminder = reminder
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
        return 2
    }
}

extension AllController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        if snapshot.itemIdentifiers.count > 0 {
            noReminderLabel.alpha = 0
        } else {
            noReminderLabel.alpha = 1
        }
    }
}


struct AllPreview: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            AllController()
        }
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
