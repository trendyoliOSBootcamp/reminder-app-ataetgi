//
//  CustomCellConfigrations.swift
//  ReminderClone
//
//  Created by Ata Etgi on 14.05.2021.
//

import UIKit

struct AddListCellBackgroundConfiguration {
    static func configuration(for state: UICellConfigurationState) -> UIBackgroundConfiguration {
        var background = UIBackgroundConfiguration.clear()
        background.cornerRadius = 20
        if state.isHighlighted || state.isSelected {
            background.backgroundColor = nil
            background.strokeOutset = 6
            background.strokeWidth = 2.5
            background.strokeColor = .systemGray2
        }
        return background
    }
}

struct AddListCellContentConfiguration: UIContentConfiguration, Hashable {
    var image: UIImage? = nil
    var tintColor: UIColor? = nil
    var listColor: UIColor? = nil
    
    func makeContentView() -> UIView & UIContentView {
        return CustomContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updatedConfig = self
        if state.isSelected || state.isHighlighted {
            updatedConfig.tintColor = .white
        }
        return updatedConfig
    }
}

class CustomContentView: UIView, UIContentView {
    init(configuration: AddListCellContentConfiguration) {
        super.init(frame: .zero)
        setupInternalViews()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfig = newValue as? AddListCellContentConfiguration else { return }
            apply(configuration: newConfig)
        }
    }
    
    private let imageView = UIImageView()
    
    private func setupInternalViews() {
        layer.cornerRadius = 20
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
        imageView.preferredSymbolConfiguration = .init(font: .preferredFont(forTextStyle: .body), scale: .large)
        imageView.contentMode = .center
        imageView.tintColor = .label
    }
    
    private var appliedConfiguration: AddListCellContentConfiguration!
    
    private func apply(configuration: AddListCellContentConfiguration) {
        guard appliedConfiguration != configuration else { return }
        backgroundColor = configuration.listColor != nil ? configuration.listColor : .systemGray3
        appliedConfiguration = configuration
        imageView.image = configuration.image

    }
}
