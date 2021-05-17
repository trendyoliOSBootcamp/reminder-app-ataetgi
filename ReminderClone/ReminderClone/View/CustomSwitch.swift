//
//  CustomSwitch.swift
//  ReminderClone
//
//  Created by Ata Etgi on 16.05.2021.
//

import UIKit

protocol SwitchDelegate: AnyObject {
    func didEndTap(_ customSwitch: CustomSwitch)
}


class CustomSwitch: UIButton {
    var status: Bool = false {
        didSet {
            self.update()
        }
    }
    var onImage = UIImage(systemName: "largecircle.fill.circle")
    var offImage = UIImage(systemName: "circle")
    
    weak var delegate: SwitchDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setStatus(false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        UIView.transition(with: self, duration: 0.10, options: .transitionCrossDissolve, animations: {
            self.status ? self.setImage(self.onImage, for: .normal) : self.setImage(self.offImage, for: .normal)
        }, completion: nil)
    }
    func toggle() {
        self.status ? self.setStatus(false) : self.setStatus(true)
        delegate?.didEndTap(self)
    }
    
    func setStatus(_ status: Bool) {
        self.status = status
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.sendHapticFeedback()
        self.toggle()
    }
    
    func sendHapticFeedback() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
    
}
