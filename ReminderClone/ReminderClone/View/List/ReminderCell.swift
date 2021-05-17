//
//  ReminderCell.swift
//  ReminderClone
//
//  Created by Ata Etgi on 16.05.2021.
//

import UIKit

class ReminderCell: UITableViewCell, UITextViewDelegate {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.textContainerInset = .init(top: 10, left: 2, bottom: 10, right: 2)
        tv.font = .systemFont(ofSize: 14)
        tv.isScrollEnabled = false
        tv.isEditable = true
        tv.backgroundColor = .clear
        return tv
    }()
    
    let isDoneSwitch = CustomSwitch()
    
    let seperator: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternaryLabel
        view.constrainHeight(constant: 1)
        return view
    }()
    
    let priortyLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = .systemOrange
        return lbl
    }()
    
    let flagImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "flag.fill"))
        iv.tintColor = .systemOrange
        return iv
    }()
    
    var textChanged: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemGroupedBackground
        textView.delegate = self
        contentView.addSubview(isDoneSwitch)
        isDoneSwitch.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,padding: .init(top: 2, left: 10, bottom: 0, right: 4), size: .init(width: 40, height: 40))
        contentView.addSubview(priortyLabel)
        priortyLabel.anchor(top: topAnchor, leading: isDoneSwitch.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 0, bottom: 0, right: 0))
        contentView.addSubview(textView)
        textView.anchor(top: topAnchor, leading: priortyLabel.trailingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 2, left: 2, bottom: 0, right: 40))
        contentView.addSubview(flagImageView)
        flagImageView.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor,padding: .init(top: 12, left: 0, bottom: 0, right: 20), size: .init(width: 14, height: 14))
        contentView.addSubview(seperator)
        seperator.anchor(top: nil, leading: priortyLabel.leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textChanged?(textView.text)
    }
    
}