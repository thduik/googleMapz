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
    func updateDirectionLabel(distance:String, directionText:String)
    func startDirection(distance:String, directionText:String)
    func endDirection()
    func directionModuleWarning(text:String)
}


class DirectionModule:NSObject {
    
    var mapView = MKMapView()
    var polyline = MKPolyline()
    var circleOverlays:[MKCircle] = []

    let locationManager = CLLocationManager()
    
    var destination:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 10.339_400, longitude: 107.082_200)
    
    var directionModuleToVCDelegate:DirectionModuleToVCDelegate?
    
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
    
    var currentDirectionText:String = ""
    var incrementStepNext:Bool = false
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        locationManager.activityType = .other
        locationManager.distanceFilter = 5
        locationManager.desiredAccuracy = CLLocationAccuracy(CLAccuracyAuthorization(rawValue: CLAccuracyAuthorization.RawValue(kCLLocationAccuracyBest))!.rawValue)
    }
    
    func startDirectionRequest() {
        
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
        
        mapView.removeOverlay(self.polyline)
        self.mapView.removeOverlays(self.circleOverlays)
        self.circleOverlays = []
        //circle overlays are only for demonstration purposes
            directions.calculate {
                [unowned self](response, error) in
            if let response = response, let route = response.routes.first {
                self.resetDirectionData()
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
                self.directionModuleToVCDelegate?.startDirection(text: self.steps[0].instructions)
            }
                
                
                
                
                
        }
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
}



extension DirectionModule:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print (currentPosition, totalPoints)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        guard let currLoc = locations.last, currentStep <= totalSteps, currentPosition < totalPoints else {
            resetDirectionData()
            return
        }
        
        while !self.checkCorrectPosition(currLoc: currLoc) {
            self.currentPosition += 1
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
                    //move this to update lo func
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
        
        directionModuleToVCDelegate?.updateDirectionLabel(distance:"\(self.distanceLeftToNextStep + distanceToNextLoc)" , directionText: self.currentDirectionText)
    }
    
    
    
    func checkCorrectPosition(currLoc:CLLocation) -> Bool {
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
        
        
        return distPrevNext > max(distCurrNext,distPrevNext)
        
        
    }
}
