//
//  MapViewPresenter.swift
//  googleMapz
//
//  Created by Macbook on 6/13/21.
//

import UIKit
import MapKit
import AVFoundation

class MapViewPresenter:NSObject {
    var mapView = MKMapView() {
        didSet {self.directionModule.mapView = mapView}
    }
    let searchBar = UISearchBar()
//    let completer = MKLocalSearchCompleter()
    var localSearch: MKLocalSearch?
    let locationManager = CLLocationManager()
    
    var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 10.364_129, longitude: 107.088_128)
    var placeAnnotations:[CustomPointAnnotation] = []
    
    var circleOverlays:[MKCircle] = []
    //var polyline = MKPolyline()
    
    var infoTableViewDelegate:VCToInfoTableViewDelegate?
    var delegateVC:PresenterToVCDelegate?
    
    var directionModule = DirectionModule()
    
    var myLocationAnnotation = CustomPointAnnotation()
    
    
    
    //Direction Module Code
    
   
    
    override init() {
        
        super.init()    
        
        
//        self.configureSearchCompleter()
        self.configureMapViewAndDelegates()
        
        
        currentLocation = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 10.339_400, longitude: 107.082_200)
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.activityType = .other
        
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = CLLocationAccuracy(CLAccuracyAuthorization(rawValue: CLAccuracyAuthorization.RawValue(kCLLocationAccuracyBest))!.rawValue)

        
        
//        mapView.mapType = .hybridFlyover
    }
}

extension MapViewPresenter: CLLocationManagerDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annoView = MKAnnotationView()
        if annotation as! NSObject == self.myLocationAnnotation {
            annoView.image = UIImage(systemName: "location.circle.fill")!
            return annoView
        }
        
        if annotation is CustomPinAnnotation {
            let markerImage = UIImage(named: "mapMarker")!.withTintColor(.blue)
            annoView.image = markerImage.withTintColor(.blue)
            
            let annotationLabel = UILabel(frame: CGRect(x: -40, y: 35, width: 100, height: 30))
            annoView.addSubview(annotationLabel)
            annotationLabel.text = annotation.title ?? "default Title"
            
            return annoView
        }
        
        return nil
    }
    
}

extension MapViewPresenter:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print ("mapview didSelect view")
        guard let annot = view.annotation as? CustomPointAnnotation else {
            print ("annot error")
            return
        }
        let placeInfo = PlaceInfoStruct(name: annot.title ?? "defaultTitle", categoryName: annot.pointOfInterestCategory?.rawValue ?? "defaultCat", address: annot.subtitle ?? "defaultAddress", phoneNumber: annot.phoneNumber, distance: "", modeOfTransport: "", url: annot.url)
        let infoTableView = InfoTableViewController(style: .plain, placeData: placeInfo)
        infoTableView.delegate = self
        self.delegateVC?.presentInfoTableView(infoTableView)
        
        self.directionModule.destination = view.annotation?.coordinate ?? self.currentLocation
        //self.startDirectionRequest(with: destP)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay.isKind(of: MKPolyline.self) {
            let renderer = MKPolylineRenderer(overlay: overlay)
//            renderer.strokeStart = 0
//            renderer.strokeEnd = 1
            renderer.strokeColor = .red
            renderer.lineWidth = 3.0
            return renderer
        }
        if overlay.isKind(of: MKCircle.self) {
            let renderer = MKCircleRenderer(overlay: overlay)
//            renderer.strokeStart = 0
//            renderer.strokeEnd = 1
            renderer.strokeColor = .red
            renderer.lineWidth = 3.0
            return renderer
        }
        
        if overlay is ImageMapOverlay {
            guard let overlayLOL = overlay as? ImageMapOverlay else {return MKOverlayRenderer() }
            let renderer = ImageMapRenderer(imageOverlay: overlayLOL)
            return renderer
            
        }
        
        
        
        return MKOverlayRenderer()
    }
    
    
    
}

extension MapViewPresenter {
    func configureMapViewAndDelegates() {
        mapView.region = .afterHours
//        completer.delegate = self
        mapView.delegate = self
    }
    
//    func configureSearchCompleter() {
//        completer.pointOfInterestFilter = MKPointOfInterestFilter(including: [.bank,.bakery, .beach, .atm, .cafe, .restaurant])
//        completer.resultTypes = .pointOfInterest
//        let currentRegion = MKCoordinateRegion(center: mapView.centerCoordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
//        completer.region = currentRegion
//    }
    
    func createSearchReques(keyword:String) -> MKLocalSearch.Request {
        //create search request from keyword, used by self.search(keyword)
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = keyword
//        searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: [.bank,.bakery, .beach, .atm, .cafe, .restaurant])
//        searchRequest.resultTypes = .pointOfInterest
        searchRequest.region = MKCoordinateRegion(center: self.currentLocation, latitudinalMeters: 5000, longitudinalMeters: 5000)
        
        return searchRequest
    }
    
    func createSearchRequest(withCompletion completion :MKLocalSearchCompletion) -> MKLocalSearch.Request {
        //create search request from Completer's Completion, used by self.search(withCompletion)
        let searchRequest = MKLocalSearch.Request(completion: completion)
        
//        searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: [.bank,.bakery, .beach, .atm, .cafe, .restaurant])
//        searchRequest.resultTypes = .pointOfInterest
        searchRequest.region = MKCoordinateRegion(center: self.currentLocation, latitudinalMeters: 5000, longitudinalMeters: 5000)
        
        return searchRequest
    }
    
    private func convertMapItemsToPointAnnotations(mapItems:[MKMapItem]) -> [CustomPointAnnotation] {
        var annArray:[CustomPointAnnotation] = []
        //convert [MapItems] and return [CustomPointAnnotation]
        mapItems.forEach { (mapItem) in
            let annotation = CustomPointAnnotation()
            annotation.coordinate = mapItem.placemark.coordinate
            annotation.subtitle = mapItem.placemark.title ?? "defaultTitle"
            annotation.title = mapItem.placemark.name ?? "defaultName"
            annotation.pointOfInterestCategory = mapItem.pointOfInterestCategory
            annotation.url = mapItem.url
            annotation.phoneNumber = mapItem.phoneNumber
            annArray.append(annotation)
            
        }
        
        return annArray
    }
    
    func search(keyword:String) {
        let searchRequest   = self.createSearchReques(keyword: keyword)
        self.searchWithRequest(request: searchRequest)
    }
    
    func search(withCompletion completion:MKLocalSearchCompletion) {
        let request = self.createSearchRequest(withCompletion:completion)
        self.searchWithRequest(request: request)
    }
    
    
    func searchWithRequest(request:MKLocalSearch.Request) {
        
        
        localSearch = MKLocalSearch(request: request)
        localSearch?.start {
            [weak self](response, erra) in
            guard let response = response, erra == nil else {
                print ("error network localSearch \(erra?.localizedDescription)")
                return
            }
            //remove current annotations
            self?.mapView.removeAnnotations(self?.placeAnnotations ?? [])
            let annArray = self?.convertMapItemsToPointAnnotations(mapItems:response.mapItems) ?? []
            //add new annotations
            self?.mapView.addAnnotations(annArray)
            self?.mapView.showAnnotations(annArray, animated: true)
            self?.placeAnnotations = annArray
        }
    }
}

extension MapViewPresenter:InfoTableViewDelegate {
    func didTapDirectionButton() {
        self.directionModule.startDirectionRequest()
        
    }
    
    
}

extension MapViewPresenter: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print ("comepleterDidUpdateResult query fragment: ", completer.queryFragment)
        
        let resultArray = completer.results.map {$0.title}
        
    }
}



//TEST CODE// TO BE DELETED LATER
//Direction Module Code

