//
//  ColorGradientView.swift
//  photos-Map
//
//  Created by Sakar Pokhrel on 2/4/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

@IBDesignable

class ColorGradientView: UIView {
    
    
    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        didSet {
           self.layer.shadowColor = shadowColor.cgColor
            
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
           self.layer.shadowRadius = shadowRadius
            
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
           
        }
    }
    
    
    @IBInspectable var OffSetWidth: CGFloat = 0 {
        didSet {
            updateView()
        }
    }
    @IBInspectable var OffSetHeight: CGFloat = 0 {
        didSet {
            updateView()
        }
    }
    
    
    private func updateView() {
         self.layer.shadowOffset = CGSize(width: OffSetWidth, height: OffSetHeight)
        
    }
    
    
    
    
}
