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
//    func updateDirectionLabel(distance:String)
    func startDirection(directHeader:DirectionInstructionView, directFooter:DirectionFooterView)
    func endDirection(directHeader:DirectionInstructionView, directFooter:DirectionFooterView)
    func directionModuleWarning(text:String)
    //func presentRouteSelectTableView(destination: String, origin: String, routeData: [RouteTableViewData])
}

protocol DirectionModuleToPresenterDelegate {
    func directionModuleInactive()
}

class DirectionModule:NSObject {
    
    var presenter:DirectionModuleToPresenterDelegate?
    var mapView:MKMapView!
    var polyline = MKPolyline()
    var circleOverlays:[MKCircle] = []

    let locationManager: CLLocationManager!
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
    
    public var currentDirectionText:String = ""
    var incrementStepNext:Bool = false
    var stepOfNextLoc:Int = 0
    
    var destinationName:String = "Default Name"
    
    let directHeader = DirectionInstructionView()
    let directFooter = DirectionFooterView()

    var directionModuleActive = false
    let startTime = CFAbsoluteTimeGetCurrent()
    
    var lastDistanceToNextLoc: CLLocationDistance = 0
    var totalDistanceToNextLocIncrease:CLLocationDistance = 0
    
    init(mapView:MKMapView, viewController:DirectionModuleToVCDelegate,locationManager:CLLocationManager, presenter: DirectionModuleToPresenterDelegate) {
        self.locationManager = locationManager
        self.directionModuleToVCDelegate = viewController
        self.presenter = presenter
        self.mapView = mapView
        super.init()
        self.directFooter.endButton.addTarget(self, action: #selector(FooterEndButtonPressed), for: .touchUpInside)
        
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.activityType = .other
        locationManager.distanceFilter = 5
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    

    
    func initiateRoute(route:MKRoute, destinationName:String) {
        
        self.configureLocationManager()
        
        guard let coord = locationManager.location?.coordinate else {return}
        self.mapView.region = MKCoordinateRegion(center: coord, latitudinalMeters: 500, longitudinalMeters: 500)
        
        self.directionModuleActive = true
        self.setupRouteData(route: route)
        
            //Add coordinate of each point in route to self.routePoints
            //this will be used
        
        self.polyline = route.polyline
        self.mapView.addOverlay(self.polyline)
        
        for i in 1 ..< route.steps.count {
            
            let step = route.steps[i]
            self.steps.append(step)
            if i == 1 {self.distanceLeftToNextStep = step.distance}
            //set distance left t0 the distance to step 1
        
            print ("step instruction is",step.instructions, "step distance is", step.distance)
            
            
            var j:Int = 0
            
            step.polyline.coordinates.forEach { (coord) in
                var nextLoc = DirectionCLLocation(latitude: coord.latitude, longitude: coord.longitude)
                var circleOverlay = MKCircle(center: coord, radius: 8)
                
                if j == 0 {
                    //isDirectionChange is defaulted to false
                    // the first point of route is the first one ( j == 0 )
                    nextLoc = DirectionCLLocation(latitude: coord.latitude, longitude: coord.longitude)
                    nextLoc.isDirectionChange = true
                    nextLoc.stepIndex = i-1
                    
                    circleOverlay = MKCircle(center: coord, radius: 22)
                }
                nextLoc.positionIndex = self.totalPoints
                self.totalPoints += 1
                self.routePoints.append(nextLoc)
                j += 1
                
                self.circleOverlays.append(circleOverlay)
                
            }
        }
        
        

        self.addDistancesToNextStep()
        self.currentDirectionText = steps[0].instructions
        self.addViewsToViewController()
        
        self.mapView.addOverlays(self.circleOverlays)
    }
    
    func addViewsToViewController() {
        
        directHeader.updateLabels(distance: String(self.steps[0].distance), instructions: self.currentDirectionText)
        directFooter.configureLabels(withEsimatedTime: self.route.expectedTravelTime, placeName: self.destinationName)
        self.directionModuleToVCDelegate?.startDirection(directHeader: self.directHeader, directFooter: self.directFooter)
    }
    
    public func resetDirectionData() {
        
        currentStep = 0
        totalSteps = 0
        totalPoints = 0
        currentPosition = 0
        routePoints = []
        distanceLeftToNextStep = 0
        distancesToNextStep = [0]
        self.steps = []
        
    }
    
    func removePolyline() {
        self.mapView.removeOverlay(self.polyline)
    }
    
    func addDistancesToNextStep() {
        //add DistancesToNextStep attribute to each route Point to facilitate calculation of remaining distance
        //remaining distance can be assumed as distacleToNextStep + distance from myLocation to next point
        
        var lastPoint:DirectionCLLocation = self.routePoints[0]
        var tempDistanceToNextStep:CLLocationDistance = self.steps[0].distance
        
        
        for i in 1..<self.totalPoints {
            let currPoint = self.routePoints[i]
            if currPoint.isDirectionChange {
                tempDistanceToNextStep = self.steps[currPoint.stepIndex].distance
                print ("point \(i) direction change distance to next step ",tempDistanceToNextStep)
            }
            
            let distance = currPoint.distance(from: lastPoint)
            tempDistanceToNextStep -= distance
            print ("point ", i,  "tempDistanceToNextStep", tempDistanceToNextStep) //"distanceToLastLoc", distance,
            currPoint.distanceToNextStep = tempDistanceToNextStep
            self.distancesToNextStep.append(tempDistanceToNextStep)
            
            lastPoint = currPoint
        }

        self.distancesToNextStep.append(0) //fix index out of range bug
        print (distancesToNextStep)
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
        print (currentPosition, currentStep, terminator: " ")
    
        
        guard let currLoc = locations.last, currentStep <= totalSteps, currentPosition < totalPoints else {
            resetDirectionData()
            return
        }
        
        var nextLoc = self.routePoints[self.currentPosition]
        var distanceToNextLoc:CLLocationDistance = 30
        
        
        for i in 0..<10 {
        
            nextLoc = self.routePoints[self.currentPosition]
            distanceToNextLoc = currLoc.distance(from: nextLoc)
    
//            print ("while loop currStep: ",self.currentStep, " currPos: ", self.currentPosition,"distanceTonextLoc", distanceToNextLoc)
        
        
            if distanceToNextLoc <= 30 {
        
                    if nextLoc.isDirectionChange {
                        //move this to update to updateLabel function in didUpdateLocation
                        
                        self.currentStep = nextLoc.stepIndex
                        self.currentDirectionText = self.steps[self.currentStep].instructions
                        
                    }
                    
                    self.currentPosition = nextLoc.positionIndex  + 1
                    //distanceLeftToNextStep array precalculated when fetching direction
        
                }
            
            
            
        
            if distanceToNextLoc > 30 {
                break
            }
        }
        
        self.distanceLeftToNextStep = self.distancesToNextStep[currentPosition] + distanceToNextLoc
        
        print ("distanceToNextStep: ", self.distancesToNextStep[currentPosition], "labelDistanceLeft", self.distanceLeftToNextStep)
        
        self.directHeader.updateLabels(distance: String(self.distanceLeftToNextStep), instructions: self.currentDirectionText)
        
    }
}




extension DirectionModule {
    @objc func FooterEndButtonPressed() {
        self.mapView.removeOverlays(self.circleOverlays)
        self.circleOverlays = []
        
        
        self.presenter?.directionModuleInactive()
        self.directionModuleActive = false
        self.resetDirectionData()
        self.removePolyline()
        self.directionModuleToVCDelegate?.endDirection(directHeader: self.directHeader, directFooter: self.directFooter)
        self.directHeader.removeFromSuperview()
        self.directFooter.removeFromSuperview()
        
        
    }
}
