//
//  HomeController+Updating.swift
//  ReminderClone
//
//  Created by Ata Etgi on 16.05.2021.
//

import UIKit
import CoreData

extension HomeController: UISearchResultsUpdating {
    
    private func findMatches(searchString: String) -> NSPredicate {
        return NSPredicate(format: "title CONTAINS[c] %@", searchString)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let request = Reminder.createFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = findMatches(searchString: searchController.searchBar.text!.trimmingCharacters(in: .whitespaces))
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: CoreDataManager.shared.persistentContainer.viewContext,
                                                    sectionNameKeyPath: "list", cacheName: nil)
        try? controller.performFetch()
        
        if let resultsController = searchController.searchResultsController as? ResultsController {
            resultsController.fetchedResultsController = controller
            resultsController.tableView.reloadData()
        }
        
    }
}
