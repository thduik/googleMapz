//
//  File.swift
//  googleMapz
//
//  Created by Macbook on 6/13/21.
//

import Foundation
import MapKit


extension CLLocationCoordinate2D {
    static let eventCenter = CLLocationCoordinate2D(latitude: 10.339_400, longitude: 107.082_200)
}

extension MKCoordinateRegion {
    static let afterHours = MKCoordinateRegion(center: CLLocationCoordinate2D.eventCenter, latitudinalMeters: 1500, longitudinalMeters: 1500)
}

