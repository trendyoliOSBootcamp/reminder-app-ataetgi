//
//  PickerViewPresenter.swift
//  ReminderClone
//
//  Created by Ata Etgi on 15.05.2021.
//

import UIKit
import CoreData

class PickerViewPresenter: UITextField, UIPickerViewDataSource, UIPickerViewDelegate {
    private lazy var doneToolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))

        let items = [flexSpace, doneButton]
        toolbar.items = items
        toolbar.sizeToFit()

        return toolbar
    }()

    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()

    var items: [PickerItem]?
    var didSelectItem: ((PickerItem) -> Void)?

    private var selectedItem: PickerItem?

    init(items: [PickerItem]?) {
        self.items = items
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        inputView = pickerView
        inputAccessoryView = doneToolbar
    }

    @objc private func doneButtonTapped() {
        if let selectedItem = selectedItem {
            didSelectItem?(selectedItem)
        }
        resignFirstResponder()
    }

    func showPicker() {
        becomeFirstResponder()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items?.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items?[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = items?[row]
    }
}

struct PickerItem {
    enum PickerType {
        case priorty, list
    }
    let name: String
    let objectId: NSManagedObjectID?
    let type: PickerType
    
    var priortyId: Int {
        switch name {
        case "Low": return 1
        case "Medium": return 2
        case "High": return 3
        default: return 0
        }
    }
    static func getName(id: Int) -> String {
        switch id {
        case 1: return "Low"
        case 2: return "Medium"
        case 3: return "High"
        default: return "None"
        }
    }
}
