//
//  HomeListCell.swift
//  ReminderClone
//
//  Created by Ata Etgi on 15.05.2021.
//

import UIKit

class HomeListCell: UITableViewCell {
    
    let cornerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(cornerView)
        cornerView.constrainHeight(constant: 36)
        cornerView.constrainWidth(constant: 36)
        cornerView.layer.cornerRadius = 18
        cornerView.centerXAnchor.constraint(equalTo: imageView!.centerXAnchor).isActive = true
        cornerView.centerYAnchor.constraint(equalTo: imageView!.centerYAnchor).isActive = true
        imageView?.tintColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
