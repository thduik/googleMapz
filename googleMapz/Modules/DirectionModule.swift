//
//  File.swift
//  googleMapz
//
//  Created by Macbook on 6/16/21.
//

import Foundation
import MapKit
import UIKit


protocol DirectionModuleToVCDelegate {
    func updateDirectionLabel(distance:String)
    func startDirection(distance:String)
    func endDirection()
    func directionModuleWarning(text:String)
    func presentRouteSelectTableView(destination: String, origin: String, routeData: [RouteTableViewData])
        
}


class DirectionModule:NSObject {
    
    var mapView = MKMapView() {
        didSet {
            let mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
            self.mapView.addGestureRecognizer(mapTap)
        }
    }
    var polyline = MKPolyline()
    var circleOverlays:[MKCircle] = []

    let locationManager = CLLocationManager()
    
    var destination:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 10.339_400, longitude: 107.082_200)
    
    var directionModuleToVCDelegate:DirectionModuleToVCDelegate?
    
    //for display available routes after finding routes
    var availableRoutes:[MKRoute] = []
    var availableRotesOverlays:[RoutePolylineOverlay] = []
    var selectedRouteIndex:Int = 0
    //var routeSelectTableView: RouteSelectionView!
    
    //math and data vars for direction function
    var currentStep:Int = 0
    var totalSteps:Int = 0
    var totalPoints:Int = 0 // to track position
    var currentPosition:Int = 0
    var routePoints:[DirectionCLLocation] = []
    var distanceLeftToNextStep:CLLocationDistance = 0
    var distancesToNextStep:[CLLocationDistance] = [] //first value has to be initiated
    var route:MKRoute = MKRoute()
    var steps:[MKRoute.Step] = []
    
    public var currentDirectionText:String = ""
    var incrementStepNext:Bool = false
    var stepOfNextLoc:Int = 0
    
    
    

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        locationManager.activityType = .other
        locationManager.distanceFilter = 5
        locationManager.desiredAccuracy = CLLocationAccuracy(CLAccuracyAuthorization(rawValue: CLAccuracyAuthorization.RawValue(kCLLocationAccuracyBest))!.rawValue)
    }
    
    func startDirectionRequest(destination:CLLocationCoordinate2D) {
        
        let request = MKDirections.Request()
        
        guard let sourceP = locationManager.location?.coordinate else {return}
        
        let sourceMark          = MKPlacemark(coordinate: sourceP)
        let destinationMark    = MKPlacemark(coordinate: self.destination)
        request.source      = MKMapItem(placemark: sourceMark)
        request.destination = MKMapItem(placemark: destinationMark)
        
        // Specify the transportation type
        request.transportType = MKDirectionsTransportType.automobile
        
        // If you're open to getting more than one route,
        // requestsAlternateRoutes = true; else requestsAlternateRoutes = false;
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        
        self.resetDirectionData()
        
        
        mapView.removeOverlay(self.polyline)
        self.mapView.removeOverlays(self.circleOverlays)
        self.mapView.removeOverlays(self.availableRotesOverlays)
//        self.mapView.removeOverlays(self.availableRotesOverlays.map {$0.polyline})
        self.circleOverlays = []
        self.availableRotesOverlays = []
        self.availableRoutes = []
        self.selectedRouteIndex = 0
        
        //circle overlays are only for demonstration purposes
            directions.calculate {
                [weak self](response, error) in
                guard let response = response, response.routes.count > 0 else {return}
                self?.availableRoutes = response.routes
                self?.displayAvailableRoutes()
                
            }
    }
    
    func removeOverlays() {
        self.mapView.removeOverlays(self.circleOverlays)
        self.mapView.removeOverlays(self.availableRotesOverlays)
        self.circleOverlays = []
        
    }
    
    func displayAvailableRoutes() {
        let distance = self.availableRoutes.first?.distance ?? 4000
        let region = MKCoordinateRegion(center: mapView.centerCoordinate, latitudinalMeters: distance * 1.5, longitudinalMeters: distance * 1.5)
        mapView.setRegion(region, animated: true)
        mapView.reloadInputViews()
        
        //create route overlay array with routeIndex to identify which Route is selected
        for i in 0..<self.availableRoutes.count {
            self.availableRotesOverlays.append(RoutePolylineOverlay(polyline: self.availableRoutes[i].polyline, routeIndex: i))
        }
        mapView.addOverlays(self.availableRotesOverlays)
        self.directionModuleToVCDelegate?.presentRouteSelectTableView(destination: "Destination", origin: "My Location", routeData: [])
        
        
    }
    
    func initiateRoute(route:MKRoute) {
        
            self.setupRouteData(route: route)

            //Add coordinate of each point in route to self.routePoints
            //this will be used
            for i in 1 ..< route.steps.count {
                
                let step = route.steps[i]
                self.steps.append(step)
                if i == 1 {self.distanceLeftToNextStep = step.distance}
                //set distance left t0 the distance to step 1
                
                print (step.instructions, step.polyline.pointCount)
                print (step.distance)
                
                var j:Int = 0
                
                step.polyline.coordinates.forEach { (coord) in
                    var nextLoc = DirectionCLLocation(latitude: coord.latitude, longitude: coord.longitude)
                    
                    if j == 0 {
                        //isDirectionChange is defaulted to false
                        // the first point of route is the first one ( j == 0 )
                        nextLoc = DirectionCLLocation(latitude: coord.latitude, longitude: coord.longitude)
                        nextLoc.isDirectionChange = true
                        nextLoc.stepIndex = i-1
                    }
                    nextLoc.positionIndex = self.totalPoints
                    self.totalPoints += 1
                    self.routePoints.append(nextLoc)
                    j += 1
                }
            }
        
            
        self.addCircleOverlays()
        self.addDistancesToNextStep()
            
        self.currentDirectionText = steps[0].instructions
        self.directionModuleToVCDelegate?.startDirection(distance: String(steps[0].distance))
        
    }
    
    public func resetDirectionData() {
        currentStep = 0
        totalSteps = 0
        totalPoints = 0
        currentPosition = 0
        routePoints = []
        distanceLeftToNextStep = 0
        distancesToNextStep = []
        self.steps = []
    }
    
    func addCircleOverlays() {
        self.routePoints.forEach { (loc) in
            var circle = DirectionMKCircle(center: loc.coordinate, radius: 10)
            
            if loc.isDirectionChange {
                circle = DirectionMKCircle(center: loc.coordinate, radius: 20)
                circle.isDirectionChange = true
            }
            
            circle.identifier = loc.positionIndex
            mapView.addOverlay(circle)
            self.circleOverlays.append(circle)
            
        }
    }
    
    
    func addDistancesToNextStep() {
        //add DistancesToNextStep attribute to each route Point to facilitate calculation of remaining distance
        //remaining distance can be assumed as distacleToNextStep + distance from myLocation to next point
        
        var lastPoint:DirectionCLLocation = self.routePoints[0]
        var tempDistanceToNextStep:CLLocationDistance = self.steps[1].distance
        for i in 1..<self.totalPoints {
            let currPoint = self.routePoints[i]
            if currPoint.isDirectionChange {
                tempDistanceToNextStep = self.steps[currPoint.stepIndex].distance
            }
            
            let distance = currPoint.distance(from: lastPoint)
            tempDistanceToNextStep -= distance
            self.distancesToNextStep.append(tempDistanceToNextStep)
            
            lastPoint = currPoint
        }

        self.distancesToNextStep.append(0) //fix index out of range bug
    }
    
    func setupRouteData(route:MKRoute) {
        self.currentPosition = 1
        self.route = route
        self.totalSteps = route.steps.count
        self.polyline = route.polyline
        self.mapView.addOverlay(self.polyline)
    }
    
    @objc func mapTapped(_ tap: UITapGestureRecognizer) {
        //add function to enable/disable if needed
        //clear self.availableRotesOverlays to distable this
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




extension DirectionModule:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print (currentPosition, totalPoints)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        guard let currLoc = locations.last, currentStep <= totalSteps, currentPosition < totalPoints else {
            resetDirectionData()
            return
        }
        
        //this function corrects if vehicle goes past current position
        
        while !self.checkCorrectPosition(currLoc: currLoc) {
            self.currentPosition += 1
            if self.incrementStepNext == true {
                // in case of change direction, we can assume vehicle moving slow and location update regularly
                // nextLoc is the beginning of nextStep
                //while loop wont be called until vehicle moves past nextLoc
                // then call while loop to update instruction label
                 
                //self.currentStep += self.stepOfNextLoc
                //distanceLeftToNextStep array precalculated when fetching directions
                self.distanceLeftToNextStep = self.distancesToNextStep[currentPosition - 1]
                self.incrementStepNext = false
                
                //This is the only place currentDirectionText is updated
                self.currentDirectionText = self.steps[self.currentStep].instructions
            }
            
            
        }
        
        if currLoc.horizontalAccuracy < 0 || currLoc.horizontalAccuracy > 60 {
            print ("inaccurateGPS")
            return
        }
        //guard against index OUTTA RANGE BITCH
        
        
        //while distance to nextLoc < 20, keep adding currentPosition until distance > 20
        var nextLoc = self.routePoints[self.currentPosition]
        var distanceToNextLoc:CLLocationDistance = 30
        
        while self.currentPosition < self.totalPoints {
            
            nextLoc = self.routePoints[self.currentPosition]
            distanceToNextLoc = currLoc.distance(from: nextLoc)
    
            print ("while loop currStep: ",self.currentStep, " currPos: ", self.currentPosition, "distanceTonextLoc", distanceToNextLoc)
            
            
            if distanceToNextLoc <= 30 {
                
                if nextLoc.isDirectionChange {
                    //move this to update to updateLabel function in didUpdateLocation
                    self.incrementStepNext = true
                    self.currentStep = nextLoc.stepIndex
                } else {
                    self.currentPosition = nextLoc.positionIndex + 1
                    //distanceLeftToNextStep array precalculated when fetching directions
                    self.distanceLeftToNextStep = self.distancesToNextStep[currentPosition - 1]
                }
            }
            if distanceToNextLoc > 30 { break }
        }
        
        if self.currentStep == self.totalSteps {
            resetDirectionData() //finished
        }
        
         
        let text = "In \(self.distanceLeftToNextStep + distanceToNextLoc) meters, \(self.steps[currentStep].instructions)"
        
        print (text, " curStep: ", self.currentStep, "currPos: ", self.currentPosition, "time elapsed: ", CFAbsoluteTimeGetCurrent() - startTime)
        
        directionModuleToVCDelegate?.updateDirectionLabel(distance:"\(self.distanceLeftToNextStep + distanceToNextLoc)")
    }
    
    
    
    func checkCorrectPosition(currLoc:CLLocation) -> Bool {
        //check by drawing perpendicular line to line of currentPoint A and lastPoint B.
        //assume currLoc is C, and P is the intersect of line perpendicular to AB that contains C, with line AB. CP perpendicular to AB, P is on AB.
        // if C is between AB, leng(AB) > either leng(AP) or leng(BP)
        // else, C is not between AB, fix by incrementing currentPosition
        
        
        if self.currentPosition < 1 || self.currentPosition == self.totalPoints - 1 {
            return true
        }
        
        let prevPoint = self.routePoints[self.currentPosition-1]
        let nextPoint = self.routePoints[self.currentPosition]
        
        if prevPoint.distance(from: nextPoint) < 20 {
            return true
        }
        
        let prevCGPoint = mapView.convert(prevPoint.coordinate, toPointTo: mapView)
        let currCGPoint = mapView.convert(currLoc.coordinate, toPointTo: mapView)
        let nextCGPoint = mapView.convert(nextPoint.coordinate, toPointTo: mapView)
        
        let a = (prevCGPoint.y - nextCGPoint.y) / (prevCGPoint.x - nextCGPoint.x)
        let b = prevCGPoint.y - prevCGPoint.x * a
        
        let perpenA:CGFloat = 0 - 1/a
        let perpenB:CGFloat = currCGPoint.y - perpenA*currCGPoint.x
        
        let resX = (perpenB - b)/(a-perpenA) //(b1-b0)/(a0-a1)
        let resY = a * resX + b // y = a*x + b
        
        let distCurrNext = pow((currCGPoint.x - nextCGPoint.x), 2) + pow((currCGPoint.y - nextCGPoint.y), 2)
        let distPrevNext = pow((prevCGPoint.x - nextCGPoint.x), 2) + pow((prevCGPoint.y - nextCGPoint.y), 2)
        let distCurrPrev = pow((prevCGPoint.x - currCGPoint.x), 2) + pow((prevCGPoint.y - currCGPoint.y), 2)
        
        
        return distPrevNext > max(distCurrNext,distCurrPrev) + 5 // improve rate of returning false marginally to improve U turn label update
        
        //return false here cause while loop to be called
        
        
    }
}
