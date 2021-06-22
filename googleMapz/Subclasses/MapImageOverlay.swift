//
//  MapImageOverlay.swift
//  googleMapz
//
//  Created by Macbook on 6/17/21.
//

import Foundation
import MapKit

class ImageMapOverlay:NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    
    var boundingMapRect: MKMapRect
    
    var image:UIImage?
    
    init(_ coord:CLLocationCoordinate2D, image:UIImage?) {
        self.image = image
        
        self.coordinate = coord
        let topLeftCoord = CLLocationCoordinate2D(latitude: coord.latitude.advanced(by: 0.001), longitude: coord.longitude.advanced(by: 0.001))
        let bottomRightCoord = CLLocationCoordinate2D(latitude: coord.latitude.advanced(by: -0.001), longitude: coord.longitude.advanced(by: -0.001))
        let topLeft = MKMapPoint(topLeftCoord)
        let bottomRight = MKMapPoint(bottomRightCoord)
        boundingMapRect = MKMapRect(x: topLeft.x, y: topLeft.y, width: fabs(topLeft.x - bottomRight.x), height: fabs(topLeft.y - bottomRight.y))
        
    }
}
