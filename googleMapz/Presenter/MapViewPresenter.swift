//
//  MapViewPresenter.swift
//  googleMapz
//
//  Created by Macbook on 6/13/21.
//

import UIKit
import MapKit
import AVFoundation

class MapViewPresenter {
    let mapView = MKMapView()
    let searchBar = UISearchBar()
    let completer = MKLocalSearchCompleter()
    var localSearch: MKLocalSearch?
    let locationManager = CLLocationManager()
    
    var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 10.339_400, longitude: 107.082_200)
    var placeAnnotations:[CustomPointAnnotation] = []
    var myLocationAnnotation = CustomPointAnnotation()
    var circleOverlays:[MKCircle] = []
    var polyline = MKPolyline()
    
    var infoTableViewDelegate:VCToInfoTableViewDelegate?
    
    init() {
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
}
