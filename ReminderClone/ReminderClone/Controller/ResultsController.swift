//
//  ResultsController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 16.05.2021.
//

import UIKit

class ResultsController: UITableViewController {
    
    let cellId = "cellId"
    
    var lists = [List:[Reminder]]()
    
    var filteredProducts = [Reminder]() {
        didSet{
            lists = Dictionary(grouping: filteredProducts, by: { $0.list })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: tableView.frame, style: .grouped)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(ReminderCell.self, forCellReuseIdentifier: cellId)
    }
}

extension ResultsController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return lists.keys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(lists.keys)[section].reminders?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ReminderCell
        let reminder = Array(lists.keys)[indexPath.section].reminders?[indexPath.row] as? Reminder
        cell.priortyLabel.text = String(repeating: "!", count: Int(reminder?.priority ?? 0))
        cell.isDoneSwitch.tintColor = Array(lists.keys)[indexPath.section].color
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
        if indexPath.row == (Array(lists.keys)[indexPath.section].reminders?.count ?? 0) - 1 {
            cell.seperator.alpha = 0
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Title"
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            let list = Array(lists.keys)[section]
            headerView.textLabel?.text = list.name
            headerView.textLabel?.textColor = list.color
            headerView.textLabel?.font = .boldSystemFont(ofSize: 18)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let reminder = Array(lists.keys)[indexPath.section].reminders?[indexPath.row] as? Reminder {
            return reminder.title.heightWithConstrainedWidth(width: tableView.frame.width - 120, font: UIFont.systemFont(ofSize: 14)) + 22
        }
        return 46
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // UIView with darkGray background for section-separators as Section Footer
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 1))
        v.backgroundColor = .secondarySystemBackground
        return v
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Section Footer height
        return 2
    }
}


