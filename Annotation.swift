//
//  Annotation.swift
//  Container
//
//  Created by Ackshaey Singh on 3/24/15.
//  Copyright (c) 2015 Ackshaey Singh. All rights reserved.
//

import MapKit

class Annotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subTitle: String
    
    init(coordinate: CLLocationCoordinate2D, title: String, subTitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subTitle = subTitle
    }
}
