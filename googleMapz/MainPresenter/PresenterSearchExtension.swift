//
//  MapViewPresenterSearchExtension.swift
//  googleMapz
//
//  Created by Macbook on 6/24/21.
//


import Foundation
import MapKit
import UIKit

//Search module

extension MapViewPresenter {
    
    
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
