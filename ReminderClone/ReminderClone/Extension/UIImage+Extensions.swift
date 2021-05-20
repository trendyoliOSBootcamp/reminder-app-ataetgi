//
//  UIImage+Extensions.swift
//  ReminderClone
//
//  Created by Ata Etgi on 14.05.2021.
//
import UIKit

extension UIImage {
    convenience init?(_ sysName: String, at pointSize: CGFloat, centeredIn size: CGSize, tintColor: UIColor = .white) {
        let cfg = UIImage.SymbolConfiguration(pointSize: pointSize)
        guard let img = UIImage(systemName: sysName, withConfiguration: cfg)?.withTintColor(.white) else { return nil }
        let x = (size.width - img.size.width) * 0.5
        let y = (size.height - img.size.height) * 0.5
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            img.draw(in: CGRect(origin: CGPoint(x: x, y: y), size: img.size))
        }
        self.init(cgImage: image.cgImage!)
    }
    
    func resizeImage(width: CGFloat, height: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContext(.init(width: width, height: height))
        let image = self
        image.draw(in: .init(x: 0, y: 0, width: 60, height: 60))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage?.withRenderingMode(.alwaysOriginal)
    }
    
    public func withRoundedCorners(radius: CGFloat? = nil, color: UIColor) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        color.setFill()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        path.addClip()
        UIRectFill(rect)
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
