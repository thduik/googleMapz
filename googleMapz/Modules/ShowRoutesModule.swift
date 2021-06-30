//
//  ShowRoutesModule.swift
//  googleMapz
//
//  Created by Macbook on 6/24/21.
//

import Foundation
import UIKit
import MapKit

protocol ShowRoutesModuleDelegate {
    func presentRouteSelectTableView(tableView:RouteSelectTableView)
    func addGestureRecognizerToCell(cell:RouteSelectTableViewCell)
}

protocol ShowRoutesModuleToPresenterDelegate {
    func initiateDirection(route:MKRoute, destinationName:String)
}

struct tableViewHeights {
    //tallest = almost fullscreeen, //medium = header + 1 cell + footer, //shortest = header only
    let tallest:CGFloat
    let medium:CGFloat
    let shortest:CGFloat
}

class ShowRoutesModule: NSObject {
    var mapView = MKMapView() {
        didSet {
            let mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
            self.mapView.addGestureRecognizer(mapTap)
        }
    }
    

    let locationManager:CLLocationManager
    
    var destination:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 10.339_400, longitude: 107.082_200)
    
    //for display available routes after finding routes
    var availableRoutes:[MKRoute] = []
    var availableRotesOverlays:[RoutePolylineOverlay] = []
    var selectedRouteIndex:Int = 0
    
    var circleOverlays:[MKCircle] = []
    
    private var currentCoord:CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var destinationName:String = ""
    
    let tableView = RouteSelectTableView()
    
    var tableViewHeightIndex:Int = 0 {
        didSet {
            if tableViewHeightIndex > 2 {tableViewHeightIndex = 2}
            if tableViewHeightIndex < 0 {tableViewHeightIndex = 0}
        }
    }
    
    let headerHeight:CGFloat = 82
    let cellHeight:CGFloat = 112
    let footerHeight:CGFloat = 52
    
    var viewController:ViewController?
    var presenter:ShowRoutesModuleToPresenterDelegate?
    
    init(mapView:MKMapView, locationManager:CLLocationManager, viewController:ViewController, presenter:ShowRoutesModuleToPresenterDelegate) {
        self.mapView = mapView
        self.locationManager = locationManager
        self.viewController = viewController
        super.init()
        
        self.presenter = presenter
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        self.mapView.addGestureRecognizer(mapTap)

        let nibba = UINib(nibName: RouteSelectXIBTableViewCell.identifier, bundle: nil)        
        self.tableView.register(nibba, forCellReuseIdentifier: RouteSelectXIBTableViewCell.identifier)
        self.tableView.register(RouteSelectTableHeader.self, forHeaderFooterViewReuseIdentifier: RouteSelectTableHeader.identifier)
        self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "footer")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.delaysContentTouches = false
        self.tableView.canCancelContentTouches = true
        
    }
    
    
    func startDirectionRequest(destination:CLLocationCoordinate2D, destinationName:String) {
        self.destination = destination
        
        let request = MKDirections.Request()
        
        guard let sourceP = locationManager.location?.coordinate else {return}
        
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
        
        
        self.removeOverlays()
        self.resetRouteData()
        
        //circle overlays are only for demonstration purposes
            directions.calculate {
                [weak self](response, error) in
                guard let response = response, response.routes.count > 0 else {return}
                self?.availableRoutes = response.routes
                self?.displayAvailableRoutes()
            }
    }
    
    func resetRouteData() {
        self.availableRoutes = []
        self.availableRotesOverlays = []
        self.selectedRouteIndex = 0
    }
    
    func removeOverlays() {
        self.mapView.removeOverlays(self.circleOverlays)
        self.mapView.removeOverlays(self.availableRotesOverlays)
        self.circleOverlays = []
        self.availableRotesOverlays = []
        self.availableRoutes = []
    }
    
    func displayAvailableRoutes() {
        let distance = self.availableRoutes.first?.distance ?? 4000
        let region = MKCoordinateRegion(center: mapView.centerCoordinate, latitudinalMeters: distance * 1.5, longitudinalMeters: distance * 1.5)
        mapView.setRegion(region, animated: true)
        mapView.reloadInputViews()
        
        //create route overlay array with routeIndex to identify which Route is selected
        for i in 0..<self.availableRoutes.count {
            let thisRoute =  self.availableRoutes[i]
            self.availableRotesOverlays.append(RoutePolylineOverlay(polyline:thisRoute.polyline, routeIndex: i))
            let idx = min(3,thisRoute.steps.count - 1)
            let thirdStepCoord = thisRoute.steps[idx].polyline.coordinate
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: thirdStepCoord.latitude, longitude: thirdStepCoord.longitude)) { (placeMarkArr, err) in
                if let firstPlacemark = placeMarkArr?.first {
                    
                    
                }
            }
        }
        mapView.addOverlays(self.availableRotesOverlays)
        
        self.viewController?.presentRouteSelectTableView(tableView: self.tableView)
    }
    
}

extension ShowRoutesModule: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableRoutes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RouteSelectXIBTableViewCell.identifier, for: indexPath) as? RouteSelectXIBTableViewCell else {return RouteSelectXIBTableViewCell()}
        let route = self.availableRoutes[indexPath.row]
        cell.configureText(roadName: "defaul", travelTime: route.expectedTravelTime, advisoryNotices: route.advisoryNotices)
        cell.indexPathRow = indexPath.row
        cell.delegate = self
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: RouteSelectTableHeader.identifier) as? RouteSelectTableHeader else {return nil}
        header.configureText(destination: self.destinationName, origin: "My Location")
        header.cancelButton.addTarget(self, action: #selector(headerCancelButtonTapper(_:)), for: .touchUpInside)
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer") else {
            return nil
        }
        footer.backgroundColor = .green
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.footerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
    
    @objc func headerCancelButtonTapper(_ sender:UIButton) {
        print ("header cancelButtonTapped in module")
        self.tableView.removeFromSuperview()
        self.mapView.removeOverlays(self.availableRotesOverlays)
        self.resetRouteData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRouteIndex = indexPath.row
        self.animateRouteChange()
//
//        let selectedRoute = self.availableRoutes[self.selectedRouteIndex]
//        self.delegatePresenter?.initiateDirection(route: selectedRoute, destinationName: self.destinationName)
//        self.removeOverlays()
//        self.resetRouteData()
    }
    
    func animateRouteChange() {
        self.mapView.removeOverlays(self.availableRotesOverlays)
        self.mapView.addOverlays(self.availableRotesOverlays)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    func fetchStreetName(coords:CLLocationCoordinate2D) {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coords.latitude, longitude: coords.longitude)) { (placeMarkArr, err) in
            if let placemarkArr = placeMarkArr{
                print ("placemark items")
                for placemark in placemarkArr {
                    let name = placemark.name ?? "nothing"
                    
                    print (name.components(separatedBy: ", "))
                    print (placemark.thoroughfare, placemark.subThoroughfare)
                }
                
            }
        }
    }
    
    
}


extension ShowRoutesModule:RouteSelectXIBTableViewCellDelegate {
    func goButtonDidTap(indexPathRow: Int) {
        print ("didTapGoButton ", indexPathRow)
        self.tableView.removeFromSuperview()
        if indexPathRow >= availableRoutes.count {return}
        self.presenter?.initiateDirection(route: self.availableRoutes[indexPathRow], destinationName: self.destinationName)
        self.removeOverlays()
        self.resetRouteData()
    }
    
    
}



    
    
//MapTap detection algorithm code
extension ShowRoutesModule {
    
    @objc func mapTapped(_ tap: UITapGestureRecognizer) {
        //add function to enable/disable if needed
        //clear self.availableRotesOverlays to distable this
        
        //test code begins
        
        
        
        //test code ends
        
        
        if self.availableRotesOverlays.count == 0 {
            return
        }
        
        if tap.state != .recognized {return}
            // Get map coordinate from touch point
        let touchPt: CGPoint = tap.location(in: self.mapView)
//           let coord: CLLocationCoordinate2D = mapView.convert(touchPt, toCoordinateFrom: map)
//            MKMapPoint().
        var nearestDistance: Double = 900500 //900km
        var nearestPolyIndex: Int = self.selectedRouteIndex
        
        // for every overlay ...
        let touchCoords = mapView.convert(touchPt, toCoordinateFrom: mapView)
        
        let touchMapPoint = MKMapPoint(touchCoords)
        
        let latMeters = mapView.region.span.latitudeDelta * 111000
        let acceptableErrorMargin:Double = latMeters / 40
        
        print ("touchMapPoint x,y:", touchMapPoint.x, touchMapPoint.y)
        print ("touchPoint x,y: ", touchPt.x, touchPt.y)
        for i in 0..<self.availableRotesOverlays.count {
            // .. if MKPolyline ...
            let polylineLOL = self.availableRotesOverlays[i].polyline
                
                // ... get the distance ...
            
            let distance:Double = distanceOf(pt: touchMapPoint, toPoly: polylineLOL )
            print ("polyline.points() x,y: ", polylineLOL.points()[0].x, polylineLOL.points()[0].y)
            print ("polyline.points() x,y: ", polylineLOL.points()[2].x, polylineLOL.points()[2].y)
            
            
                // ... and find the nearest one
            if distance < acceptableErrorMargin && distance < nearestDistance {
                nearestDistance = distance
                nearestPolyIndex = i
            }
        }
        
        self.selectedRouteIndex = nearestPolyIndex
//        self.mapView.reloadInputViews()
        self.mapView.removeOverlays(self.availableRotesOverlays)
        self.mapView.addOverlays(self.availableRotesOverlays)
        print (nearestDistance, self.selectedRouteIndex)
    }

    private func distanceOf(pt: MKMapPoint, toPoly poly: MKPolyline) -> Double {
        var distance: Double = Double(MAXFLOAT)
        for n in 0..<poly.pointCount - 1 {
            let ptA = poly.points()[n]
            let ptB = poly.points()[n + 1]
            let xDelta: Double = ptB.x - ptA.x
            let yDelta: Double = ptB.y - ptA.y
            if xDelta == 0.0 && yDelta == 0.0 {
                // Points must not be equal
                continue
            }
            let u: Double = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            var ptClosest: MKMapPoint
            if u < 0.0 {
                ptClosest = ptA
            }
            else if u > 1.0 {
                ptClosest = ptB
            }
            else {
                ptClosest = MKMapPoint(x: ptA.x + u * xDelta, y: ptA.y + u * yDelta)
            }

            distance = min(distance, ptClosest.distance(to: pt))
        }
        return distance
    }
}

