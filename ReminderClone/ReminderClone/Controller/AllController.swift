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
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView = UITableView(frame: tableView.frame, style: .grouped)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(ReminderCell.self, forCellReuseIdentifier: cellId)
        tableView.layoutMargins = .zero
        tableView.separatorInset = .init(top: 0, left: 44, bottom: 0, right: 0)
        title = "All"
        navigationController?.navigationBar.prefersLargeTitles = true
        let apperance = UINavigationBarAppearance()
        apperance.largeTitleTextAttributes = [.foregroundColor: UIColor.darkGray]
        navigationController?.navigationBar.standardAppearance = apperance
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = true
    }
}

extension AllController {
    
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
        cell.layoutMargins = .zero
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Title"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            let list = (fetchedResultsController.sections![section].objects!.first as! Reminder).list
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
        v.backgroundColor = .secondarySystemBackground
        return v
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
}

extension AllController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
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
