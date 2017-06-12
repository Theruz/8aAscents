//
//  UIImageHelpers.swift
//  Ascents
//
//  Created by Theophile on 01.05.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    
    
    /// Takes an image and returns a new image rotated by a chosen angle
    ///
    /// - Parameter rotationAngle: The rotation angle as a UnitAngle
    /// - Returns: A new rotated image
    func rotated(by rotationAngle: Measurement<UnitAngle>) -> UIImage? {
        
        guard let cgImage = self.cgImage else { return nil }
        
        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        
        return renderer.image { renderContext in
            
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
    
    /**
     Create an image from color with size (1, height)
     
     - parameter color:  color to create image
     - parameter height: height of image
     
     - returns: UIImage
     */
    class func from(_ color: UIColor, width: CGFloat = 1, height: CGFloat = 1.0) -> UIImage {
        let rect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: width, height: height)
        if UIScreen.instancesRespond(to: #selector(getter: self.scale)) {
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        } else {
            UIGraphicsBeginImageContext(rect.size)
        }
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
