//
//  HomeHeaderCell.swift
//  ReminderClone
//
//  Created by Ata Etgi on 15.05.2021.
//

import UIKit


class HomeHeaderCell: UICollectionViewCell {
    
    let iconSize: CGFloat = 30
    
    let imageBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    let iconView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        return iv
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 28)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let containerView = UIView()
        contentView.addSubview(containerView)
        containerView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor,
                             padding: .init(top: 12, left: 12, bottom: 12, right: 12))
        contentView.addSubview(imageBackground)
        
        imageBackground.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: nil,
                               size: .init(width: iconSize, height: iconSize))
        imageBackground.layer.cornerRadius = iconSize / 2
        
        imageBackground.addSubview(iconView)
        iconView.contentMode = .center
        iconView.centerInSuperview(size: .init(width: 24, height: 24))
        
        addSubview(countLabel)
        countLabel.anchor(top: imageBackground.topAnchor, leading: nil, bottom: nil, trailing: containerView.trailingAnchor)
        
        addSubview(titleLabel)
        titleLabel.anchor(top: imageBackground.bottomAnchor, leading: imageBackground.leadingAnchor, bottom: nil, trailing: nil,
                          padding: .init(top: 12, left: 0, bottom: 0, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
