//
//  UIImage.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 18/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import UIKit

extension UIImage {
    
    func circled(targetSize: CGSize) -> UIImage? {

        let side = min(targetSize.width, targetSize.height)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        
        defer {  UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext()
            else { return nil }
        
        self.draw(in: CGRect(origin: .zero, size: targetSize), blendMode: .copy, alpha: 1.0)
        
        context.setBlendMode(.copy)
        context.setFillColor(UIColor.clear.cgColor)
        
        let rect = CGRect(origin: .zero, size: targetSize)
        let rectPath = UIBezierPath(rect: rect)
        let circlePath = UIBezierPath(ovalIn: rect)
        rectPath.append(circlePath)
        rectPath.usesEvenOddFillRule = true
        rectPath.fill()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func scaled() -> UIImage? {
        guard self.scale != UIScreen.main.scale
            else { return self }
        let k = self.scale / UIScreen.main.scale
        let scaledSize = CGSize(width: self.size.width * k, height: self.size.height * k)
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, UIScreen.main.scale)
        
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext()
            else { return nil }
        self.draw(in: CGRect(origin: .zero, size: scaledSize), blendMode: .copy, alpha: 1.0)
        context.setBlendMode(.copy)
        context.setFillColor(UIColor.clear.cgColor)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
