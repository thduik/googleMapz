
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
    
    var directionModule: DirectionModule!
    
    var myLocationAnnotation = CustomPointAnnotation()
    
    var showRouteModule: ShowRoutesModule!
    
    var viewController:ViewController?
    //Direction Module Code
    
    let startTime = CFAbsoluteTimeGetCurrent()
    
    init(mapView:MKMapView, viewController:ViewController) {
        self.locationManager.stopUpdatingLocation()
        self.mapView = mapView
        self.delegateVC = viewController
        self.viewController = viewController
//        self.directionModule.directionModuleToVCDelegate = viewController
        super.init()
        self.directionModule = DirectionModule(mapView: self.mapView, viewController: viewController, locationManager: self.locationManager, presenter: self)
        self.showRouteModule = ShowRoutesModule(mapView: self.mapView, locationManager: self.locationManager, viewController: self.viewController!, presenter: self)
        mapView.delegate = self
        self.configureMapView()
        currentLocation = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 10.339_400, longitude: 107.082_200)
        
        self.configureLocationManager()
        

    }
    
    
    
    private func configureLocationManager() {
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.activityType = .other
        
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = 20
    }
    
    func configureMapView() {
        mapView.region = .afterHours
        mapView.delegate = self as! MKMapViewDelegate
    }
}

extension MapViewPresenter: DirectionModuleToPresenterDelegate {
    func directionModuleInactive() {
        //get back delegate role of location manager and reconfigure
        self.locationManager.delegate = self
        self.configureLocationManager()
    }
    
    
}

extension MapViewPresenter: ShowRoutesModuleToPresenterDelegate {
    func initiateDirection(route: MKRoute, destinationName: String) {
        self.directionModule.initiateRoute(route: route, destinationName: destinationName)
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print ("location Manager didUpdate location")
    }
}





//MapView and CLManager delegate methods

extension MapViewPresenter:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if self.directionModule.directionModuleActive { //in navigation mode
            return
        }
        
        guard let annot = view.annotation as? CustomPointAnnotation else {
            
            return
        }
        let placeInfo = PlaceInfoStruct(name: annot.title ?? "defaultTitle", categoryName: annot.pointOfInterestCategory?.rawValue ?? "defaultCat", address: annot.subtitle ?? "defaultAddress", phoneNumber: annot.phoneNumber, distance: "", modeOfTransport: "", url: annot.url, coordinate: annot.coordinate)
        
        let infoTableView = InfoTableViewController(style: .plain, placeData: placeInfo)
        infoTableView.delegate = self
        self.delegateVC?.presentInfoTableView(infoTableView)
        
        let coord = view.annotation?.coordinate ?? self.currentLocation
        
        self.showRouteModule.destination = coord
        
        //test code only.  delete later
        
        
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routeOverlay = overlay as? RoutePolylineOverlay {
            print ("detected route overlay")
            let renderer = MKPolylineRenderer(overlay: routeOverlay.polyline)
//            renderer.strokeStart = 0
//            renderer.strokeEnd = 1
            
            renderer.strokeColor = .blue
            renderer.lineWidth = 8.0
            if routeOverlay.routeIndex != self.showRouteModule.selectedRouteIndex {
                renderer.lineDashPattern = [2,10]
            }
            
            return renderer
        }
        
        if overlay.isKind(of: MKPolyline.self) {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 8.0
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
    func didTapDirectionButton(destinationName: String, destinationCoordinate: CLLocationCoordinate2D) {
        self.showRouteModule.startDirectionRequest(destination: destinationCoordinate, destinationName: destinationName)
    }
}





//TEST CODE// TO BE DELETED LATER
//Direction Module Code

