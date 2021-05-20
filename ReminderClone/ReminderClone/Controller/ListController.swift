//
//  ListController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 16.05.2021.
//

import UIKit
import SwiftUI

class ListController: UITableViewController, AddEditReminderDelegate {
    
    func didUpdated() {
        tableView.reloadData()
    }
    
    init(list: List?) {
        self.list = list
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var addReminderButton = createReminderButton(selector: #selector(addNewReminder))
    
    lazy var noReminderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNewReminder)))
        return label
    }()
    
    let reuseIdentifier = "reuseIdentifier"
    var list: List!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.layoutMargins = .zero
        tableView.separatorInset = .init(top: 0, left: 44, bottom: 0, right: 0)
        tableView.backgroundView = noReminderLabel
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.register(ReminderCell.self, forCellReuseIdentifier: reuseIdentifier)
        toolbarItems = [UIBarButtonItem(customView: addReminderButton), .flexibleSpace()]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        title = list?.name ?? "All"
        addReminderButton.tintColor = list?.color ?? .systemBlue
        let apperance = UINavigationBarAppearance()
        apperance.largeTitleTextAttributes = [.foregroundColor: list?.color ?? .darkGray]
        navigationController?.navigationBar.standardAppearance = apperance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if tempReminder != nil && tempReminder.title.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            list.removeFromReminders(tempReminder)
            let indexPath = IndexPath(item: ((list?.reminders?.count ?? 0)), section: 0)
            CoreDataManager.shared.persistentContainer.viewContext.delete(tempReminder)
            tempReminder = nil
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    var tempReminder: Reminder!
    
    @objc private func addNewReminder() {
        print(#function)
        view.endEditing(true)
        if tempReminder != nil && tempReminder.title.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            list.removeFromReminders(tempReminder)
            let indexPath = IndexPath(item: ((list?.reminders?.count ?? 0)), section: 0)
            CoreDataManager.shared.persistentContainer.viewContext.delete(tempReminder)
            tempReminder = nil
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else if tempReminder == nil {
            let indexPath = IndexPath(item: ((list?.reminders?.count ?? 0)), section: 0)
            let newReminder = Reminder(context: CoreDataManager.shared.persistentContainer.viewContext)
            newReminder.date = Date()
            newReminder.list = list
            tempReminder = newReminder
            list?.addToReminders(newReminder)
            tableView.insertRows(at: [indexPath], with: .automatic)
            noReminderLabel.text = nil
            if let cell = tableView.cellForRow(at: indexPath) as? ReminderCell {
                cell.textView.becomeFirstResponder()
            }
        } else {
            tempReminder = nil
        }
    }
}


// MARK: - TableView Methods

extension ListController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.reminders?.count ?? 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ReminderCell
        let reminder = list?.reminders?[indexPath.row] as? Reminder
        cell.reminder = reminder
        cell.textChanged { [weak tableView] (newText: String) in
            if let reminder = reminder {
                reminder.title = newText
            }
            DispatchQueue.main.async {
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
        }
        cell.layoutMargins = .zero
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let reminders = list?.reminders, reminders.count == 0 {
            return tableView.frame.height - (tableView.contentSize.height + 300)

        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let reminders = list?.reminders, reminders.count == 0 {
            noReminderLabel.text = "No Reminders"
            return noReminderLabel
        } else {
            noReminderLabel.text = nil
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let reminder = list?.reminders?[indexPath.row] as? Reminder {
            return reminder.title.heightWithConstrainedWidth(width: tableView.frame.width - 120, font: UIFont.systemFont(ofSize: 16)) + 26
        }
        return 46
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (_, _, completion) in
            guard let reminder = (tableView.cellForRow(at: indexPath) as? ReminderCell)?.reminder else {
                completion(false)
                return
            }
            CoreDataManager.shared.persistentContainer.viewContext.delete(reminder)
            CoreDataManager.shared.saveContext { error in
                guard error == nil else {
                    completion(false)
                    return
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                NotificationCenter.default.post(name: .updateReminder, object: nil)
                completion(true)
            }
        }
        
        let detailsAction = UIContextualAction(style: .normal, title: "Details") {
            [weak self] (_, _, completion) in
            guard let self = self, let reminder = (tableView.cellForRow(at: indexPath) as? ReminderCell)?.reminder  else {
                completion(false)
                return
            }
            let reminderController = AddEditReminderController()
            reminderController.delegate = self
            reminderController.reminder = reminder
            self.present(UINavigationController(rootViewController: reminderController), animated: true, completion: nil)
            completion(true)
        }
        
        let flagAction = UIContextualAction(style: .normal, title: "Flag") { _, _, completion in
            guard let reminder = (tableView.cellForRow(at: indexPath) as? ReminderCell)?.reminder else {
                completion(false)
                return
            }
            reminder.flag.toggle()
            CoreDataManager.shared.saveContext { error in
                guard error == nil else {
                    completion(false)
                    return
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
                NotificationCenter.default.post(name: .updateReminder, object: nil)
                completion(true)
            }
        }
        
        deleteAction.backgroundColor = .systemRed
        detailsAction.backgroundColor = .systemGray
        flagAction.backgroundColor = .systemOrange
        return UISwipeActionsConfiguration(actions: [deleteAction, flagAction, detailsAction])
    }
    
}

struct ListPreview: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            UINavigationController(rootViewController: ListController(list: nil))
        }
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
