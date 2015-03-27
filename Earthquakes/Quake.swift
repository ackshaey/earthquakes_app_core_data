//
//  Quake.swift
//  Earthquakes
//
//  Created by Ackshaey Singh on 3/26/15.
//  Copyright (c) 2015 Ackshaey Singh. All rights reserved.
//

import Foundation
import CoreData

class Quake: NSManagedObject {

    @NSManaged var quakeTitle: String
    @NSManaged var quakeMagnitude: NSNumber
    @NSManaged var quakeDate: NSDate
    @NSManaged var location: Location

}
