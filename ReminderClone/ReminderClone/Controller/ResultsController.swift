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
    var fetchedResultsController: NSFetchedResultsController<Reminder>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .systemGroupedBackground
        tableView.allowsSelection = false
        tableView.layoutMargins = .zero
        tableView.tableFooterView = UIView()
        tableView.separatorInset = .init(top: 0, left: 44, bottom: 0, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.register(ReminderCell.self, forCellReuseIdentifier: cellId)
    }
}

extension ResultsController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ReminderCell
        let reminder = fetchedResultsController?.object(at: indexPath)
        cell.reminder = reminder
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Title"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            let list = (fetchedResultsController?.sections![section].objects!.first as! Reminder).list
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
        let reminder = fetchedResultsController?.object(at: indexPath)
        return (reminder?.title.heightWithConstrainedWidth(width: tableView.frame.width - 120, font: UIFont.systemFont(ofSize: 16)) ?? 0) + 28
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


