//
//  ViewController.swift
//  googleMapz
//
//  Created by Macbook on 6/12/21.
//

import UIKit
import MapKit
import AVFoundation

class ViewController: UIViewController {
    var mapView = MKMapView()
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
    
    var presenter:MapViewPresenter
    
    private let pointsOfInterestFiler = MKPointOfInterestFilter(including: [.nightlife,.bank,.hospital,.restaurant,.atm,.bakery,.hotel,.movieTheater])
    
    init() {
        presenter = MapViewPresenter()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        //presenter = MapViewPresenter()
        super.viewWillLayoutSubviews()
        
        mapView.frame = CGRect(x: 0, y:82 , width: view.bounds.width, height: view.bounds.height-82)
        searchBar.frame = CGRect(x: 0, y:30 , width: view.bounds.width, height: 52)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additional setup after loading the view.
            // Create a GMSCameraPosition that tells the map to display the
            // coordinate -33.86,151.20 at zoom level 6.
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        view.addSubview(mapView)
        view.addSubview(searchBar)
        self.configureSearchCompleter()
        self.configureMapViewAndDelegates()
        currentLocation = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 10.339_400, longitude: 107.082_200)
        locationManager.startUpdatingLocation()
      }
    
    
    
    
    
    
}

extension ViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        for res in completer.results {
            print (res.title)
            print (res.subtitle)
        }
    }
    
    
}

extension ViewController:MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let destP = view.annotation?.coordinate else {return}
        guard let annot = view.annotation as? CustomPointAnnotation else {return}
        let placeInfo = PlaceInfoStruct(name: annot.title ?? "defaultTitle", categoryName: annot.pointOfInterestCategory?.rawValue ?? "defaultCat", address: annot.subtitle ?? "defaultAddress", phoneNumber: annot.phoneNumber, distance: "", modeOfTransport: "", url: annot.url)
        let infoTableView = InfoTableViewController(style: .plain, placeData: placeInfo)
        present(infoTableView, animated: true, completion: nil)
        
        //self.startDirectionRequest(with: destP)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print ("overlay renderer called")
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
        
        return MKOverlayRenderer()
    }
    
    func startDirectionRequest(with destination:CLLocationCoordinate2D) {
        
        let request = MKDirections.Request()
        let sourceP         = self.currentLocation
        
        let sourceMark          = MKPlacemark(coordinate: sourceP)
        let destinationMark    = MKPlacemark(coordinate: destination)
        request.source      = MKMapItem(placemark: sourceMark)
        request.destination = MKMapItem(placemark: destinationMark)
        
        // Specify the transportation type
        request.transportType = MKDirectionsTransportType.automobile

        // If you're open to getting more than one route,
        // requestsAlternateRoutes = true; else requestsAlternateRoutes = false;
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        mapView.removeOverlay(self.polyline)
        self.circleOverlays = []
        
        for circle in self.circleOverlays {
            print ("removing circle")
            self.mapView.removeOverlay(circle)
        }
        // Now we have the routes, we can calculate the distance using
            directions.calculate {
                [unowned self](response, error) in
            if let response = response, let route = response.routes.first {
                
                let renderer = MKPolylineRenderer(polyline: route.polyline)
                self.polyline = route.polyline
                self.mapView.addOverlay(self.polyline)
                
                for i in 0 ..< route.steps.count {
                    let step = route.steps[i]
                    
                    print(step.instructions)
                    print(step.distance)
                    let region = CLCircularRegion(center: step.polyline.coordinate,
                                                  radius: 20,
                                                  identifier: "\(i)")
                    self.locationManager.startMonitoring(for: region)
                    let circle = MKCircle(center: region.center, radius: region.radius)
                    self.mapView.addOverlay(circle)
                    self.circleOverlays.append(circle)
                }
            }
        }
    }
    
}
//PREP FUNC BELOW

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print ("updated location")
        currentLocation = locations.last?.coordinate ?? CLLocationCoordinate2D(latitude: 10.339_400, longitude: 107.082_200)
        let pointAnno = CustomPointAnnotation()
        pointAnno.title = "My Location"
        pointAnno.coordinate = currentLocation
        mapView.addAnnotation(pointAnno)
        mapView.showAnnotations([pointAnno], animated: false)
        
    }
}




//PREP FUNCS

extension ViewController {
    func configureMapViewAndDelegates() {
        mapView.region = .afterHours
        completer.delegate = self
        searchBar.delegate = self
        mapView.delegate = self
    }
    
    func configureSearchCompleter() {
        completer.pointOfInterestFilter = self.pointsOfInterestFiler
        completer.resultTypes = .pointOfInterest
        let currentRegion = MKCoordinateRegion(center: mapView.centerCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        completer.region = currentRegion
    }
    
    func createSearchReques(keyword:String) -> MKLocalSearch.Request {
        //configure and return MKLocalSearch.Request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = keyword
        searchRequest.pointOfInterestFilter = self.pointsOfInterestFiler
        searchRequest.resultTypes = .pointOfInterest
        searchRequest.region = MKCoordinateRegion(center: self.currentLocation, latitudinalMeters: 2000, longitudinalMeters: 2000)
        
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
        
        let searchRequest = self.createSearchReques(keyword: keyword)
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start {
            [weak self](response, erra) in
            guard let response = response, erra == nil else {
                print ("error network localSearch \(erra?.localizedDescription)")
                return
            }
            //remove current annotations
            self?.mapView.removeAnnotations(self?.placeAnnotations ?? [])
            let annArray = self?.convertMapItemsToPointAnnotations(mapItems:response.mapItems) ?? []
            self?.mapView.addAnnotations(annArray)
            self?.mapView.showAnnotations(annArray, animated: true)
            self?.placeAnnotations = annArray
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3 {
            completer.queryFragment = searchText
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var keyword = searchBar.text ?? ""
        keyword = keyword.trimmingCharacters(in: .whitespaces)
        if keyword.count <= 2 {return}
        self.search(keyword: keyword)
    }
}


protocol VCToInfoTableViewDelegate {
    func didReceiveDirectionData(routeData:DirectionStruct)
}


struct DirectionStruct {
    let distance:String
    let time:String
    let modeOfTransport:String
}
