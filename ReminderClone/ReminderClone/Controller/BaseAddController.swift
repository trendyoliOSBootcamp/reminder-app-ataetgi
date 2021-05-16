//
//  AddController.swift
//  ReminderClone
//
//  Created by Ata Etgi on 15.05.2021.
//

import UIKit

class BaseAddController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupNavigationBar()
    }
    
    
    fileprivate func setupNavigationBar() {
        let navigationBarAppearence = UINavigationBarAppearance()
        navigationBarAppearence.backgroundColor = .systemGroupedBackground
        navigationBarAppearence.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = navigationBarAppearence
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
        title = "BaseAddController"
    }
    @objc func doneTapped() {
        dismiss(animated: true, completion: nil)
    }
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
}
