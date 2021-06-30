//
//  PlaceInfoStruct.swift
//  googleMapz
//
//  Created by Macbook on 6/14/21.
//

import Foundation
import MapKit

struct PlaceInfoStruct {
    let name:String
    var categoryName:String?
    var address:String?
    var phoneNumber:String?
    var distance:String?
    var modeOfTransport:String?
    var url:URL?
    var coordinate:CLLocationCoordinate2D
}
