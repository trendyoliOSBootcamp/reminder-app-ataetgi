//
//  AddReminderController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 15.05.2021.
//

import UIKit
import SwiftUI
import CoreData

class AddReminderController: BaseAddController{
    
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
                tableView.reloadData()
            }
        }
    }
    
    var lists: [PickerItem]? {
        didSet{
            selectedList = lists?.last
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
        
        CoreDataManager.shared.createReminder(date: Date(), flag: flagSwitch.isOn, note: notesTextView.text ?? "", priority: Int16(selectedPriorty.priortyId), title: titleTextView.text ?? "", list: list)
    }
    
    let flagIdentifier = "flagIdentfier"
}

extension AddReminderController: UITableViewDataSource {
    
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
            cell.placeholderLabel.text = placeholders[indexPath.row]
            if indexPath.row == 0 {
                if titleTextView == nil {
                    cell.textView.becomeFirstResponder()
                }
                titleTextView = cell.textView
            } else {
                notesTextView = cell.textView
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
            let cell = UITableViewCell(style: .default, reuseIdentifier: flagIdentifier)
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

extension AddReminderController: UITableViewDelegate, TextViewCellProtocol {
    
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


struct AddReminderPreview: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            AddReminderController()
        }
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            
        }
    }
}
