//
//  MKMultiPointExtension.swift
//  googleMapz
//
//  Created by Macbook on 6/19/21.
//

import Foundation
import MapKit

public extension MKMultiPoint {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)

        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))

        return coords
    }
}
