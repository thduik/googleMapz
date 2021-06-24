//
//  MKPolygonTapRecognizerExtension.swift
//  googleMapz
//
//  Created by Macbook on 6/23/21.
//

import Foundation
import MapKit

extension MKPolygon {
    func contain(coor: CLLocationCoordinate2D) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let currentMapPoint: MKMapPoint = MKMapPoint(coor)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
        if polygonRenderer.path == nil {
            return false
        }else{
            return polygonRenderer.path.contains(polygonViewPoint)
        }
    }
}
