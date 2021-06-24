//
//  File.swift
//  googleMapz
//
//  Created by Macbook on 6/23/21.
//

import Foundation
import MapKit

class RoutePolylineOverlay:NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    var polyline:MKPolyline
    //identify which route
    var routeIndex:Int
    
    init(polyline:MKPolyline, routeIndex:Int) {
        
        self.polyline = polyline
        self.routeIndex = routeIndex
        self.coordinate = polyline.coordinate
        self.boundingMapRect = polyline.boundingMapRect
    }
}
