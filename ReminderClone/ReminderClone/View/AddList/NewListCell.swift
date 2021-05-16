//
//  NewListCell.swift
//  ReminderClone
//
//  Created by Ata Etgi on 14.05.2021.
//

import UIKit

class CustomConfigurationCell: UICollectionViewCell {
    var image: UIImage? 
    var listColor: UIColor?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        backgroundConfiguration = AddListCellBackgroundConfiguration.configuration(for: state)
        var content = AddListCellContentConfiguration().updated(for: state)
        content.image = image
        content.listColor = listColor
        contentConfiguration = content
    }
}
