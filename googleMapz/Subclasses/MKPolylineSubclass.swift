//
//  MKPolylineSubclass.swift
//  googleMapz
//
//  Created by Macbook on 6/18/21.
//

import Foundation
import MapKit

class MapLolPolyline: MKPolyline {
    
}

class RoutePolyline: MKPolyline {
    let routeIndex:Int
    init(routeIndex:Int) {
        self.routeIndex = routeIndex
        super.init()
    }
}

