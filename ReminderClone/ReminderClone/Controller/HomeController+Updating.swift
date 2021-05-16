//
//  HomeController+Updating.swift
//  ReminderClone
//
//  Created by Ata Etgi on 16.05.2021.
//

import UIKit

extension HomeController: UISearchResultsUpdating {
    
    private func findMatches(searchString: String) -> NSPredicate {
        return NSPredicate(format: "title CONTAINS[c] %@", searchString)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // Update the filtered array based on the search text.
        let searchResults = fetchedReminderResultsController.fetchedObjects
        
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString =
            searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        
        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            findMatches(searchString: searchString)
        }
        
        let finalCompoundPredicate =
            NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
        
        let filteredResults = searchResults?.filter { finalCompoundPredicate.evaluate(with: $0) }
        
        if let resultsController = searchController.searchResultsController as? ResultsController {
            resultsController.filteredProducts = filteredResults ?? []
            resultsController.tableView.reloadData()
        }
        
    }
}
