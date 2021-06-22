//
//  DirectionCLLocation.swift
//  googleMapz
//
//  Created by Macbook on 6/19/21.
//

import Foundation
import MapKit

class DirectionCLLocation:CLLocation {
    var positionIndex:Int = 0
    var isDirectionChange:Bool = false
    //var distanceToNextLoc:CLLocationDistance = 0
    var stepIndex:Int = 0
}
