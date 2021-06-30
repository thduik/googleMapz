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
//    var infoTableViewDelegate:VCToInfoTableViewDelegate?
    
    var zoomInButton = UIButton()
    var zoomOutButton = UIButton()
    
    let completionTableView = UITableView()
    
    //handle tableview of LocalSearchCompleter completion results
    var completionPresenter: CompletionTableViewPresenter!
    var presenter: MapViewPresenter!
     
    //views for direction module
    
    
    private let pointsOfInterestFiler = MKPointOfInterestFilter(including: [.nightlife,.bank,.hospital,.restaurant,.atm,.bakery,.hotel,.movieTheater])
//
    
    
    var pinLocationAnnotation = CustomPointAnnotation()
    private var userTrackingButton: MKUserTrackingButton!
    
//    init() {
//          self.presenter = MapViewPresenter(mapView: self.mapView)
//          super.init(nibName: nil, bundle: nil)
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
        self.presenter = MapViewPresenter(mapView: self.mapView, viewController: self)
        self.completionPresenter = CompletionTableViewPresenter(tableView: self.completionTableView,  parentVC: self, mapView: self.mapView)
        userTrackingButton = MKUserTrackingButton(mapView: self.mapView)
        self.addAllSubViews()
        self.addConstraints()
        searchBar.delegate = self
        self.configureButtons() //button UI and addTarget here too
        self.hideKeyboardWhenTappedAround()
        
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


extension ViewController:PresenterToVCDelegate {
    func presentInfoTableView(_ infoTableView: InfoTableViewController) {
        present(infoTableView, animated: true, completion: nil)
    }
}



extension ViewController:DirectionModuleToVCDelegate{
    func endDirection(directHeader: DirectionInstructionView, directFooter: DirectionFooterView) {
        self.view.layoutIfNeeded()
    }
    
    func updateDirectionLabel(distance: String) {
        
    }
    
    func startDirection(directHeader: DirectionInstructionView, directFooter: DirectionFooterView) {
        print ("Adding subview")

        self.view.addSubview(directHeader)
        directHeader.frame = CGRect(x: 0, y: 30, width: self.view.bounds.width, height: 172)
        directHeader.backgroundColor = .systemBackground
        
        self.view.addSubview(directFooter)
        directFooter.frame = CGRect(x: 0 , y: self.view.bounds.height - 88, width: self.view.bounds.width, height: 88)
        directFooter.backgroundColor = .systemBackground
        
        UIView.animate(withDuration: 1) {
            
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
    
    func directionModuleWarning(text: String) {
        self.presentAlert(text: text)
    }
    
    
}

protocol VCToInfoTableViewDelegate {
    func didReceiveRouteData(routeData:DirectionStruct)
}

extension ViewController: ShowRoutesModuleDelegate {
    func addGestureRecognizerToCell(cell: RouteSelectTableViewCell) {
        print ("cell lol")
        let tapGestureRecognizer = MyRecognizer(target: self, action: #selector(tapGestureRecognizedGoButton(_:)))
        cell.goButton.addGestureRecognizer(tapGestureRecognizer)
        cell.goButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    @objc func tapGestureRecognizedGoButton(_ sender:MyRecognizer) {
        print ("tap detected")
//        self.selectedRouteIndex = sender.routeIndex
//        self.animateRouteChange()
    }
    
    @objc func buttonTapped(_ sender:UIButton) {
        print ("buttonTapped")
    }

    func presentRouteSelectTableView(tableView: RouteSelectTableView) {
        view.addSubview(tableView)
        let tableHeight = view.bounds.height / 2
        tableView.frame = CGRect(x: 0, y: view.bounds.height - tableHeight, width: view.bounds.width, height: tableHeight)
        tableView.reloadData()
    }
}




//UI AND SEARCH BAR DELEGATE CODE ONLY
extension ViewController {
    
    @objc func hideTableView() {
        self.completionTableView.isHidden = true
    }
    func configureButtons() {
    
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

