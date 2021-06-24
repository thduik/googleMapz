
//extensions in other files

import UIKit
import MapKit
import AVFoundation
import CarPlay

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
    
    var showRouteModule: ShowRoutesModule
    
    
    //Direction Module Code
    
   
    
    override init() {
        
        super.init()
//        self.configureSearchCompleter()
        self.configureMapViewAndDelegates()
        
        
        currentLocation = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 10.339_400, longitude: 107.082_200)
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self as! CLLocationManagerDelegate
        locationManager.requestAlwaysAuthorization()
        locationManager.activityType = .other
        
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = CLLocationAccuracy(CLAccuracyAuthorization(rawValue: CLAccuracyAuthorization.RawValue(kCLLocationAccuracyBest))!.rawValue)
//        mapView.mapType = .hybridFlyover
    }
    
    func configureMapViewAndDelegates() {
        mapView.region = .afterHours
//        completer.delegate = self
        mapView.delegate = self as! MKMapViewDelegate
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





//MapView and CLManager delegate methods

extension MapViewPresenter:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annot = view.annotation as? CustomPointAnnotation else {
            
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
        if let routeOverlay = overlay as? RoutePolylineOverlay {
            print ("detected route overlay")
            let renderer = MKPolylineRenderer(overlay: routeOverlay.polyline)
//            renderer.strokeStart = 0
//            renderer.strokeEnd = 1
            renderer.strokeColor = .blue
            renderer.lineWidth = 8.0
            if routeOverlay.routeIndex != self.directionModule.selectedRouteIndex {
                renderer.lineDashPattern = [0,10]
            }
            
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




extension MapViewPresenter:InfoTableViewDelegate {
    func didTapDirectionButton() {
        self.directionModule.startDirectionRequest()
    }
}





//TEST CODE// TO BE DELETED LATER
//Direction Module Code

