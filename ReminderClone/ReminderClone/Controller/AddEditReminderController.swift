//
//  AddReminderController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 15.05.2021.
//

import UIKit
import CoreData

protocol AddEditReminderDelegate: AnyObject {
    func didUpdated()
}

class AddEditReminderController: BaseAddController {
    
    var reminder: Reminder? {
        didSet{
            guard let reminder = reminder else { return }
            flagSwitch.isOn = reminder.flag
            selectedPriorty = PickerItem(name: "\(PickerItem.getName(id: Int(reminder.priority)))", objectId: nil, type: .priorty)
        }
    }
    
    weak var delegate: AddEditReminderDelegate?
    
    private let flagSwitch: UISwitch = {
        let flag = UISwitch()
        flag.isOn = false
        return flag
    }()
    
    private lazy var priorityPickerViewPresenter: PickerViewPresenter = {
        let pickerViewPresenter = PickerViewPresenter(items: priorities)
        pickerViewPresenter.didSelectItem = { [weak self] item in
            self?.selectedPriorty = item
        }
        return pickerViewPresenter
    }()
    
    private lazy var listPickerViewPresenter: PickerViewPresenter = {
        let pickerViewPresenter = PickerViewPresenter(items: lists)
        pickerViewPresenter.didSelectItem = { [weak self] item in
            self?.selectedList = item
        }
        return pickerViewPresenter
    }()
    
    var titleTextView: UITextView!
    var notesTextView: UITextView!
    
    fileprivate func openPicker(sender: Int) {
        if sender == 3 {
            priorityPickerViewPresenter.showPicker()
        } else {
            listPickerViewPresenter.showPicker()
        }
    }
    
    let placeholders = ["Title", "Notes"]
    
    let priorities: [PickerItem] = [
        .init(name: "None", objectId: nil, type: .priorty),
        .init(name: "Low", objectId: nil, type: .priorty),
        .init(name: "Medium", objectId: nil, type: .priorty),
        .init(name: "High", objectId: nil, type: .priorty),
    ]
    
    var selectedPriorty: PickerItem = .init(name: "None", objectId: nil , type: .priorty) {
        didSet{
            if tableView != nil {
                tableView.reloadSections(IndexSet(integer: 3), with: .none)
            }
        }
    }
    
    var lists: [PickerItem] = [PickerItem]() {
        didSet{
            if let reminder = reminder{
                selectedList = PickerItem(name: reminder.list.name, objectId: reminder.list.objectID, type: .list)
            } else {
                selectedList = lists.first
            }
        }
    }
    
    var selectedList: PickerItem? {
        didSet{
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lists = CoreDataManager.shared.fetchLists().reversed().map { list in
            return PickerItem(name: list.name, objectId: list.objectID, type: .list)
        }
        
        title = "New Reminder"
        setupTableView()
        navigationItem.rightBarButtonItem?.title = "Add"
        view.addSubview(priorityPickerViewPresenter)
        view.addSubview(listPickerViewPresenter)
    }
    
    fileprivate func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TextViewCell.self, forCellReuseIdentifier: "textFieldReuse")
    }
    
    override func doneTapped() {
        super.doneTapped()
        guard let objectId = selectedList?.objectId else { return }
        guard let list = CoreDataManager.shared.persistentContainer.viewContext.object(with:  objectId) as? List else { return }
        
        if let reminder = reminder {
            reminder.flag = flagSwitch.isOn
            reminder.title = titleTextView.text
            reminder.note = notesTextView.text
            reminder.priority = Int16(selectedPriorty.priortyId)
            CoreDataManager.shared.saveContext {[weak self] error in
                guard let self = self else { return }
                guard error == nil else { return }
                NotificationCenter.default.post(name: .updateReminder, object: nil)
                self.delegate?.didUpdated()
            }
        } else {
            CoreDataManager.shared.createReminder(date: Date(), flag: flagSwitch.isOn, note: notesTextView.text ?? "", priority: Int16(selectedPriorty.priortyId), title: titleTextView.text, list: list)
        }
    }
}

extension AddEditReminderController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldReuse", for: indexPath) as! TextViewCell
            if indexPath.row == 0 {
                if titleTextView == nil {
                    cell.textView.becomeFirstResponder()
                }
                titleTextView = cell.textView
                cell.textView.text = reminder?.title
                cell.placeholderLabel.text = reminder?.title == nil ? placeholders[indexPath.row] : ""
            } else {
                notesTextView = cell.textView
                cell.textView.text = reminder?.note
                cell.placeholderLabel.text = reminder?.note == nil ? placeholders[indexPath.row] : ""
            }
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 1 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = selectedList?.name
            cell.textLabel?.text = "List"
            return cell
        } else if indexPath.section == 2 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = .none
            cell.imageView?.image = UIImage(systemName: "flag.fill")
            cell.imageView?.tintColor = .white
            let bgView = RoundedView()
            bgView.backgroundColor = .systemOrange
            cell.contentView.addSubview(bgView)
            bgView.constrainHeight(constant: 32)
            bgView.constrainWidth(constant: 32)
            bgView.centerXAnchor.constraint(equalTo: cell.imageView!.centerXAnchor).isActive = true
            bgView.centerYAnchor.constraint(equalTo: cell.imageView!.centerYAnchor).isActive = true
            cell.contentView.sendSubviewToBack(bgView)
            cell.accessoryView = flagSwitch
            cell.textLabel?.text = "Flag"
            return cell
        }else {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.accessoryType = .disclosureIndicator
            cell.detailTextLabel?.text = selectedPriorty.name
            cell.tag = 2
            cell.textLabel?.text = "Priorty"
            return cell
        }
    }
    
}

extension AddEditReminderController: UITableViewDelegate, TextViewCellDelegate {
    
    func titleHasChange(isHidden: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isHidden
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == [0,1] {
            return 150
        }
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 || indexPath.section == 1 {
            openPicker(sender: indexPath.section)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
