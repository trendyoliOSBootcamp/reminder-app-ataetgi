//
//  TextFieldCell.swift
//  ReminderClone
//
//  Created by Ata Etgi on 15.05.2021.
//

import UIKit
protocol TextViewCellDelegate: AnyObject {
    func titleHasChange(isHidden: Bool)
}

class TextViewCell: UITableViewCell, UITextViewDelegate {
    
    static let reuseIdentifier = "TextViewCellReuseIdentifier"
    weak var delegate: TextViewCellDelegate?
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 20)
        tv.backgroundColor = .clear
        return tv
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .quaternaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textView)
        textView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor,
                        padding: .init(top: 5, left: 10, bottom: 5, right: 10))
        textView.addSubview(placeholderLabel)
        placeholderLabel.anchor(top: textView.topAnchor, leading: textView.leadingAnchor, bottom: nil, trailing: nil,
                                padding: .init(top: 10, left: 10, bottom: 0, right: 0))
        textView.delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.hasText
        if textView.tag == 0 {
            delegate?.titleHasChange(isHidden: textView.hasText)
        }
    }
    
}
