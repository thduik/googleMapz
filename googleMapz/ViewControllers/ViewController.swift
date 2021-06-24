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
    let directHeader = DirectionInstructionView()
    let addPinButton = UIButton()
//    var infoTableViewDelegate:VCToInfoTableViewDelegate?
    var presenter = MapViewPresenter()
    var zoomInButton = UIButton()
    var zoomOutButton = UIButton()
    
    let completionTableView = UITableView()
    
    //handle tableview of LocalSearchCompleter completion results
    var completionPresenter: CompletionTableViewPresenter!
    
    private let pointsOfInterestFiler = MKPointOfInterestFilter(including: [.nightlife,.bank,.hospital,.restaurant,.atm,.bakery,.hotel,.movieTheater])
//
    
    
    var pinLocationAnnotation = CustomPointAnnotation()
    private var userTrackingButton: MKUserTrackingButton!
    
//    init() {
//        presenter = MapViewPresenter()
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewWillLayoutSubviews() {
        //presenter = MapViewPresenter()
        super.viewWillLayoutSubviews()
        
        
        zoomOutButton.frame = CGRect(x: view.bounds.width - 50, y: view.bounds.height - 70, width: 42, height: 52)
        zoomInButton.frame = CGRect(x: view.bounds.width - 50, y: view.bounds.height - 112, width: 42, height: 42)
        userTrackingButton.frame = CGRect(x: 12, y: view.bounds.height - 112, width: 42, height: 42)
//        addPinButton.frame = CGRect(x: 0, y: 92, width: 100, height: 48)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.completionPresenter = CompletionTableViewPresenter(tableView: self.completionTableView,  parentVC: self, mapView: self.mapView)
        userTrackingButton = MKUserTrackingButton(mapView: self.mapView)
        self.addAllSubViews()
        self.addConstraints()
        searchBar.delegate = self
        presenter.mapView = self.mapView
        mapView.delegate = presenter as! MKMapViewDelegate
        
        presenter.delegateVC = self
        presenter.directionModule.directionModuleToVCDelegate = self
        
        self.configureButtons() //button UI and addTarget here too
        
        self.hideKeyboardWhenTappedAround()
        //        let imageOverlay = ImageMapOverlay(presenter.currentLocation, image: UIImage(named: "animeGirl1"))
        //        mapView.addOverlay(imageOverlay)
        
      }
    
    func addAllSubViews() {
        view.addSubview(mapView)
        view.addSubview(searchBar)
        
        view.addSubview(zoomInButton)
        view.addSubview(zoomOutButton)
        view.addSubview(userTrackingButton)
        view.addSubview(completionTableView)
        
        
        completionTableView.isHidden = true
        completionTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
       
    }
    
    @objc func addPinButtonTapped() {
        guard let coordVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "InputCoordinateViewController") as? InputCoordinateViewController else {return}
        coordVC.delegate = self
        self.present(coordVC, animated: true, completion: nil)
        
        //this func is for converting touch CGPoint to mapview coordinate in mapview
        mapView.convert(CGPoint(x: 12, y: 44), toCoordinateFrom: mapView)
    }
    
    @objc func zoomOutButtonTapped() {
        
        let span = mapView.region.span
        let newSpan = MKCoordinateSpan(latitudeDelta: span.latitudeDelta*5/3, longitudeDelta: span.longitudeDelta*5/3)
        
        self.mapView.region = MKCoordinateRegion(center: mapView.region.center, span: newSpan)

        
    }
    
    @objc func zoomInButtonTapped() {
        
        let span = mapView.region.span
        let newSpan = MKCoordinateSpan(latitudeDelta: span.latitudeDelta*3/5, longitudeDelta: span.longitudeDelta*3/5)
        
        self.mapView.region = MKCoordinateRegion(center: mapView.region.center, span: newSpan)
        
    }
}

extension ViewController:CompletionPresenterToVCDelegate {
    func didSelectCompletion(_ completion: MKLocalSearchCompletion) {
        self.presenter.search(withCompletion: completion)
    }
    
}

extension ViewController: InputCoordinateViewControllerDelegate {
    func didFinishInputCoordinate(coord: CLLocationCoordinate2D, name:String) {
        let pinAnnotation = CustomPinAnnotation()
        pinAnnotation.coordinate = coord
        pinAnnotation.title = name
        mapView.addAnnotation(pinAnnotation)
        mapView.showAnnotations([pinAnnotation], animated: true)
    }
}


extension ViewController:PresenterToVCDelegate {
    func presentInfoTableView(_ infoTableView: InfoTableViewController) {
        present(infoTableView, animated: true, completion: nil)
    }
}



extension ViewController:DirectionModuleToVCDelegate{
    func presentRouteSelectTableView(destination: String, origin: String, routeData: [RouteTableViewData]) {
//        let routeSelectTableView = RouteSelectionView(destination: "Destination", origin: "My Location", routeData: routeData)
//        view.addSubview(routeSelectTableView)
//        routeSelectTableView.frame = CGRect(x: 0, y: view.bounds.height*3/5, width: view.bounds.width, height: view.bounds.height*2/5)
        
    }
    
    func startDirection(distance: String) {
        view.addSubview(directHeader)
        directHeader.frame = CGRect(x: 0, y: 30, width: view.bounds.width, height: 172)
        directHeader.updateLabels(distance: distance, instructions: self.presenter.directionModule.currentDirectionText)
        directHeader.backgroundColor = .systemBackground
    }
    
    func updateDirectionLabel(distance: String) {
        directHeader.updateLabels(distance: distance, instructions: self.presenter.directionModule.currentDirectionText)
    }
    
    
    
    func directionModuleWarning(text: String) {
        self.presentAlert(text: text)
    }
    
    
    
    
    
    func endDirection() {
        
    }
}



protocol VCToInfoTableViewDelegate {
    func didReceiveRouteData(routeData:DirectionStruct)
}
//UI CODE ONLY
extension ViewController {
    
    @objc func hideTableView() {
        self.completionTableView.isHidden = true
    }
    func configureButtons() {
        addPinButton.addTarget(self, action: #selector(addPinButtonTapped), for: .touchUpInside)
        addPinButton.setTitle("Add Pin", for: .normal)
        addPinButton.backgroundColor = .systemBackground
        addPinButton.setTitleColor(.black, for: .normal)
    
        zoomInButton.addTarget(self, action: #selector(zoomInButtonTapped), for: .touchUpInside)
        zoomInButton.setTitle("+", for: .normal)
        zoomInButton.backgroundColor = .systemBackground
        zoomInButton.setTitleColor(.black, for: .normal)
        
        zoomOutButton.addTarget(self, action: #selector(zoomOutButtonTapped), for: .touchUpInside)
        zoomOutButton.setTitle("-", for: .normal)
        zoomOutButton.backgroundColor = .systemBackground
        zoomOutButton.setTitleColor(.black, for: .normal)
        
        
        
        userTrackingButton.backgroundColor = .systemBackground
    }
    
    func addConstraints() {
       
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 52).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
//        searchBar.searchBarStyle = .minimal
        searchBar.searchBarStyle = .default
        searchBar.barStyle = .default
        searchBar.placeholder = "Search Maps"

        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        completionTableView.translatesAutoresizingMaskIntoConstraints = false
        completionTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        completionTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        completionTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        completionTableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    func presentAlert(text:String) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.hideTableView()
        self.completionPresenter.doesNotShowTable(true)
        searchBar.showsCancelButton = false
        searchBar.text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        
        if searchText.count >= 3 {
            self.completionPresenter.doesNotShowTable(false)
            self.completionPresenter.configureSearchCompleterRegion()
            self.completionPresenter.completer.queryFragment = searchText
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print (self.mapView.centerCoordinate)
        self.completionTableView.isHidden = true
        self.completionPresenter.doesNotShowTable(true)
        var keyword = searchBar.text ?? ""
        keyword = keyword.trimmingCharacters(in: .whitespaces)
        if keyword.count <= 2 {return}
        self.presenter.search(keyword: keyword)
        self.searchBar.showsCancelButton = true
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        searchBar.showsCancelButton = true
        view.layoutIfNeeded()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
}
