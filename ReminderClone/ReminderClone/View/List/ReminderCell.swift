//
//  ReminderCell.swift
//  ReminderClone
//
//  Created by Ata Etgi on 16.05.2021.
//

import UIKit

class ReminderCell: UITableViewCell, UITextViewDelegate, SwitchDelegate {
    
    static let reuseIdentifier = "ReminderCell"
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.textContainerInset = .init(top: 10, left: 2, bottom: 10, right: 2)
        tv.font = .systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.isEditable = true
        tv.backgroundColor = .clear
        return tv
    }()
    
    lazy var isDoneSwitch: CustomSwitch = {
        let sw = CustomSwitch()
        sw.delegate = self
        return sw
    }()
    
    let priortyLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = .systemOrange
        return lbl
    }()
    
    let flagImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "flag.fill"))
        iv.tintColor = .systemOrange
        return iv
    }()
    
    var textChanged: ((String) -> Void)?
    
    var reminder: Reminder? {
        didSet {
            guard let reminder = reminder else { return }
            priortyLabel.text = String(repeating: "!", count: Int(reminder.priority) )
            isDoneSwitch.tintColor = reminder.done ? .gray : reminder.list.color
            isDoneSwitch.setStatus(reminder.done)
            textView.text = reminder.title
            textView.textColor = reminder.done ? .gray : .label
            flagImageView.tintColor = reminder.done ? .gray : .systemOrange
            flagImageView.alpha = (reminder.flag) ? 1 : 0
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemGroupedBackground
        textView.delegate = self
        contentView.addSubview(isDoneSwitch)
        isDoneSwitch.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil,
                            padding: .init(top: 0, left: 8, bottom: 0, right: 4), size: .init(width: 44, height: 44))
        contentView.addSubview(priortyLabel)
        priortyLabel.anchor(top: topAnchor, leading: isDoneSwitch.trailingAnchor, bottom: nil, trailing: nil,
                            padding: .init(top: 12, left: 0, bottom: 0, right: 0))
        contentView.addSubview(textView)
        textView.anchor(top: topAnchor, leading: priortyLabel.trailingAnchor, bottom: nil, trailing: trailingAnchor,
                        padding: .init(top: 2, left: 2, bottom: 0, right: 40))
        contentView.addSubview(flagImageView)
        flagImageView.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor,
                             padding: .init(top: 12, left: 0, bottom: 0, right: 20), size: .init(width: 14, height: 14))
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" else { return }
        CoreDataManager.shared.saveContext { error in
            guard error == nil else {return}
            NotificationCenter.default.post(name: .updateReminder, object: nil)
        }
    }
    
    func didEndTap(_ customSwitch: CustomSwitch) {
        textView.textColor = customSwitch.status ? .gray : .label
        flagImageView.tintColor = customSwitch.status ? .gray : .systemOrange
        isDoneSwitch.tintColor = customSwitch.status ? .gray : reminder?.list.color
        reminder?.done = customSwitch.status
        CoreDataManager.shared.saveContext(completion: nil)
    }
}
