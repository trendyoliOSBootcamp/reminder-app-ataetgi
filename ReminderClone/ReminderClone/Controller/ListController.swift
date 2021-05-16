//
//  ListController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 16.05.2021.
//

import UIKit
import SwiftUI

class ListController: UITableViewController {

    init(list: List?) {
        self.list = list
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var noReminderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNewReminder)))
        return label
    }()
    

    
    let reuseIdentifier = "reuseIdentifier"
    var list: List?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIView()
        tableView.allowsSelection = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.backgroundView = noReminderLabel
        tableView.register(ReminderCell.self, forCellReuseIdentifier: reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        title = list?.name ?? "All"
        let apperance = UINavigationBarAppearance()
        apperance.largeTitleTextAttributes = [.foregroundColor: list?.color ?? .darkGray]
        navigationController?.navigationBar.standardAppearance = apperance
    }
    
    @objc private func addNewReminder() {
        print(#function)
        view.endEditing(true)
    }
}



extension ListController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.reminders?.count ?? 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ReminderCell
        let reminder = list?.reminders?[indexPath.row] as? Reminder
        cell.priortyLabel.text = String(repeating: "!", count: Int(reminder?.priority ?? 0))
        cell.isDoneSwitch.tintColor = list?.color
        cell.isDoneSwitch.setStatus(reminder?.done ?? false)
        cell.textView.text = reminder?.title 
        cell.flagImageView.alpha = (reminder?.flag ?? true) ? 1 : 0
        cell.textChanged { [weak tableView] (newText: String) in
            if let reminder = reminder {
                reminder.title = newText
            }
            DispatchQueue.main.async {
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
        }
        
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
            return reminder.title.heightWithConstrainedWidth(width: tableView.frame.width - 120, font: UIFont.systemFont(ofSize: 14)) + 22
        }
        return 46
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
