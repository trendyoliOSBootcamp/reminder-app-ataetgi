//
//  UIViewController+NavApperance.swift
//  ReminderClone
//
//  Created by Ata Etgi on 16.05.2021.
//

import UIKit

extension UIViewController {
    func configureNavigationBar(largeTitleColor: UIColor?, titleColor: UIColor? = nil, backgroundColor: UIColor?, tintColor: UIColor?, title: String?, preferredLargeTitle: Bool?) {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            if let largeTitleColor = largeTitleColor {
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
            }
            if let titleColor = titleColor {
                navBarAppearance.titleTextAttributes = [.foregroundColor: titleColor]
            }
            
            if let backgroundColor = backgroundColor {
                navBarAppearance.backgroundColor = backgroundColor
                
            }
            
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.compactAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            
            if let preferredLargeTitle = preferredLargeTitle {
                navigationController?.navigationBar.prefersLargeTitles = preferredLargeTitle
            }
            
            navigationController?.navigationBar.isTranslucent = false
            if let tintColor = tintColor {
                navigationController?.navigationBar.tintColor = tintColor
            }
            navigationItem.title = title
            
        } else {
            if let backgroundColor = backgroundColor {
                navigationController?.navigationBar.barTintColor = backgroundColor
            }
            if let tintColor = tintColor {
                navigationController?.navigationBar.tintColor = tintColor
            }
            navigationController?.navigationBar.isTranslucent = false
            navigationItem.title = title
        }
    }
    
    
    // MARK: - Create Reminder Button

    func createReminderButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        button.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: config), for: .normal)
        button.titleLabel?.font = UIFontMetrics.default.scaledFont(for: .boldSystemFont(ofSize: 18))
        button.setTitle("  New Reminder", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
}
