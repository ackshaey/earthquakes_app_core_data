//
//  Location.swift
//  Earthquakes
//
//  Created by Ackshaey Singh on 3/26/15.
//  Copyright (c) 2015 Ackshaey Singh. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var locationName: String
    @NSManaged var depth: NSNumber
    @NSManaged var link: String
    @NSManaged var quake: Quake

}
