//
//  CompletionTableViewPresenter.swift
//  googleMapz
//
//  Created by Macbook on 6/21/21.
//

import Foundation
import UIKit
import MapKit

protocol CompletionPresenterToVCDelegate {
    func didSelectCompletion(_ completion:MKLocalSearchCompletion)
}

class CompletionTableViewPresenter:NSObject {
    var tableView:UITableView!
    var completionArray = [MKLocalSearchCompletion]()
    var delegateVC:CompletionPresenterToVCDelegate?
    let completer = MKLocalSearchCompleter()
    var mapView:MKMapView!
    
    init(tableView:UITableView, parentVC:CompletionPresenterToVCDelegate, mapView:MKMapView) {
        super.init()
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.delegateVC = parentVC
        completer.delegate = self
        self.mapView = mapView
        self.configureSearchCompleterRegion()
        
        completer.pointOfInterestFilter = MKPointOfInterestFilter(including: [.bank,.bakery, .beach, .atm, .cafe, .restaurant])
        completer.resultTypes = .pointOfInterest
        
    }
    
    public func configureSearchCompleterRegion() {
        print (mapView.centerCoordinate)
        let currentRegion = MKCoordinateRegion(center: mapView.centerCoordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        completer.region = currentRegion
    }
}

extension CompletionTableViewPresenter: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.completionArray = completer.results
        tableView.reloadData()
        self.tableView.isHidden = self.completionArray.isEmpty
    }
}

extension CompletionTableViewPresenter: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.completionArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.completionArray[indexPath.row].title + ". " + self.completionArray[indexPath.row].title
        // Configure the cell...
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < completionArray.count else {return}
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegateVC?.didSelectCompletion(completionArray[indexPath.row])
        self.tableView.isHidden = true
    }
    
    
}
