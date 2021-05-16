//
//  PaddedTextField.swift
//  ReminderClone
//
//  Created by Ata Etgi on 14.05.2021.
//

import UIKit
open class PaddedTextField: UITextField {
    public var textInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .init(top: textInsets.top, left: textInsets.left, bottom: textInsets.bottom, right: textInsets.right))
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: .init(top: textInsets.top, left: textInsets.left, bottom: textInsets.bottom, right: textInsets.right + 5))
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: .init(top: textInsets.top, left: textInsets.left, bottom: textInsets.bottom, right: textInsets.right)))
    }
    
    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect{
        let rect = super.clearButtonRect(forBounds: bounds)
        return rect.offsetBy(dx: -10, dy: 0)
    }
}
