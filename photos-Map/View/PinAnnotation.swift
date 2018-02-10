//
//  PinAnnotation.swift
//  photos-Map
//
//  Created by Sakar Pokhrel on 2/4/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import MapKit

class PinAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
    
}
