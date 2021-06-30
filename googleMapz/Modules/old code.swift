//
//  old code.swift
//  googleMapz
//
//  Created by Macbook on 6/29/21.
//

import Foundation

//func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    print (currentPosition, totalPoints)
//    
//   
//    
//    guard let currLoc = locations.last, currentStep <= totalSteps, currentPosition < totalPoints else {
//        resetDirectionData()
//        return
//    }
//    
//    //this function corrects if vehicle goes past current position
//    
//    while !self.checkCorrectPosition(currLoc: currLoc) {
//        self.currentPosition += 1
//        if self.incrementStepNext == true {
//            // in case of change direction, we can assume vehicle moving slow and location update regularly
//            // nextLoc is the beginning of nextStep
//            //while loop wont be called until vehicle moves past nextLoc
//            // then call while loop to update instruction label
//            
//            //distanceLeftToNextStep array precalculated when fetching directions
//            self.distanceLeftToNextStep = self.distancesToNextStep[currentPosition - 1]
//            self.incrementStepNext = false
//            
//            //This is the only place currentDirectionText is updated
//            self.currentDirectionText = self.steps[self.currentStep].instructions
//            
//            print (self.distancesToNextStep)
//            print (self.distanceLeftToNextStep)
//        }
//    }
//    
//    if currLoc.horizontalAccuracy < 0 || currLoc.horizontalAccuracy > 60 {
//        print ("inaccurateGPS")
//        return
//    }
//    //guard against index OUTTA RANGE BITCH
//    
//    
//    //while distance to nextLoc < 20, keep adding currentPosition until distance > 20
//    //position climb algorithm
//    var nextLoc = self.routePoints[self.currentPosition]
//    var distanceToNextLoc:CLLocationDistance = 30
//    
//    for i in 0..<5 {
//        
//        nextLoc = self.routePoints[self.currentPosition]
//        distanceToNextLoc = currLoc.distance(from: nextLoc)
//
//        print ("while loop currStep: ",self.currentStep, " currPos: ", self.currentPosition, "distanceTonextLoc", distanceToNextLoc)
//        
//        
//        if distanceToNextLoc <= 30 {
//            
//            if nextLoc.isDirectionChange {
//                //move this to update to updateLabel function in didUpdateLocation
//                self.incrementStepNext = true
//                self.currentStep = nextLoc.stepIndex
//                break
//            } else {
//                self.currentPosition = nextLoc.positionIndex + 1
//                //distanceLeftToNextStep array precalculated when fetching directions
//                self.distanceLeftToNextStep = self.distancesToNextStep[currentPosition - 1]
//            }
//           
//        }
//        
//        if distanceToNextLoc > 30 {
//            break
//        }
//    }
//    
//    if self.currentStep == self.totalSteps {
//        resetDirectionData() //finished
//    }
//    
//     
//    let text = "In \(self.distanceLeftToNextStep + distanceToNextLoc) meters, \(self.steps[currentStep].instructions)"
//    
//    print (text, " curStep: ", self.currentStep, "currPos: ", self.currentPosition, "time elapsed: ", CFAbsoluteTimeGetCurrent() - startTime)
//    
//    self.directHeader.updateLabels(distance:"\(self.distanceLeftToNextStep + distanceToNextLoc)" , instructions: self.currentDirectionText)
//
//}
//
//
//
//func checkCorrectPosition(currLoc:CLLocation) -> Bool {
//    //check by drawing perpendicular line to line of currentPoint A and lastPoint B.
//    //assume currLoc is C, and P is the intersect of line perpendicular to AB that contains C, with line AB. CP perpendicular to AB, P is on AB.
//    // if C is between AB, leng(AB) > either leng(AP) or leng(BP)
//    // else, C is not between AB, fix by incrementing currentPosition
//    
//    
//    if self.currentPosition < 1 || self.currentPosition == self.totalPoints - 1 {
//        return true
//    }
//    
//    let prevPoint = self.routePoints[self.currentPosition-1]
//    let nextPoint = self.routePoints[self.currentPosition]
//    
//    if prevPoint.distance(from: nextPoint) < 20 {
//        return true
//    }
//    
//    let prevCGPoint = mapView.convert(prevPoint.coordinate, toPointTo: mapView)
//    let currCGPoint = mapView.convert(currLoc.coordinate, toPointTo: mapView)
//    let nextCGPoint = mapView.convert(nextPoint.coordinate, toPointTo: mapView)
//    
//    let a = (prevCGPoint.y - nextCGPoint.y) / (prevCGPoint.x - nextCGPoint.x)
//    let b = prevCGPoint.y - prevCGPoint.x * a
//    
//    //perpen line ax + b = y => a = perpenA, b = perpenB, resX, resY is the point on prev-next line
//    
//    let perpenA:CGFloat = 0 - 1/a
//    let perpenB:CGFloat = currCGPoint.y - perpenA*currCGPoint.x
//    
//    let resX = (perpenB - b)/(a-perpenA) //(b1-b0)/(a0-a1)
//    let resY = a * resX + b // y = a*x + b
//    
//    //no need to square root, all for comparison purposes
//    
//    let distResNext = pow((resX - nextCGPoint.x), 2) + pow((resY - nextCGPoint.y), 2)
//    let distPrevNext = pow((prevCGPoint.x - nextCGPoint.x), 2) + pow((prevCGPoint.y - nextCGPoint.y), 2)
//    let distResPrev = pow((prevCGPoint.x - resX), 2) + pow((prevCGPoint.y - resY), 2)
//    
//    
//    return distPrevNext > max(distResNext,distResPrev) - 20 //power of 2, real value around 4.48
//    // improve rate of returning true
//    
//    //return false here cause while loop to be called
//    
//    
//}
