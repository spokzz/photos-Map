//
//  popVC.swift
//  photos-Map
//
//  Created by Sakar Pokhrel on 2/6/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class PopVC: UIViewController {

    @IBOutlet weak var popImageView: UIImageView!
    
    var imageToPop: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageToPop = imageToPop {
            popImageView.image = imageToPop
        }
        addDoubleTap()
       
    }
    
   private func addDoubleTap() {
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
    }
    
    @objc private func handleDoubleTap() {
        
        dismiss(animated: true, completion: nil)
    
    }

}
