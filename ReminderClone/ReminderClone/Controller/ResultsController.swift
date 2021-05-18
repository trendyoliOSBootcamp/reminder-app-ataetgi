//
//  ResultsController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 16.05.2021.
//

import UIKit
import CoreData

class ResultsController: UITableViewController {
    
    let cellId = "cellId"
    
    var fetchedResultsController: NSFetchedResultsController<Reminder>!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(ReminderCell.self, forCellReuseIdentifier: cellId)
    }
}

extension ResultsController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ReminderCell
        let reminder = fetchedResultsController.object(at: indexPath)
        cell.reminder = reminder
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Title"
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            let list = (fetchedResultsController.sections![section].objects!.first as! Reminder).list
            headerView.textLabel?.text = list.name
            headerView.textLabel?.textColor = list.color
            headerView.textLabel?.font = .boldSystemFont(ofSize: 18)
            var bgConfig = UIBackgroundConfiguration.listPlainHeaderFooter()
            bgConfig.backgroundColor = tableView.backgroundColor
            headerView.backgroundConfiguration = bgConfig
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let reminder = fetchedResultsController.object(at: indexPath)
        return reminder.title.heightWithConstrainedWidth(width: tableView.frame.width - 120, font: UIFont.systemFont(ofSize: 16)) + 26
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


