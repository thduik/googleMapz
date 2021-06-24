#  README



Direction Module

Available routes

These variables are used to display different available routes, allowing users to choose 1

    for display available routes after finding routes
    var availableRoutes:[MKRoute] = []
    var availableRotesOverlays:[RoutePolylineOverlay] = []
    var selectedRouteIndex:Int = 0
    
    When available routes are displayed
    mapTapped() gesture recognizer used to calculate distance between tapPoint and closest route
    All point pairs in each route is checked for perpendicular line distance from tapPoint to line formed by point pair, to find the closest distance from tapPoint to the whole Polyline
    
    
    
Key concepts for routing algorithms

all points in each polyline of the route's polyline are stored IN ORDER in **var routePoints**
each point assigned a **position**
var **currentPosition** determines which 2 points user is **between**
example: **currentPosition** == 2 => between point 1 and 2

    whenever user goes within 30 meters range of nextPoint point, **currentPosition**  += 1

There's algorithm to **REDETERMINE POSITION**, in case of loss of gps signal for a while:
while !self.checkCorrectPosition(currLoc: currLoc) {currentPosition += 1}
not correct position? => currentPosition += 1 is the solution!

Example: real position == 12 but **currrentPosition** == 8, => update **currrentPosition** to == 12







