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
    let directHeader = UILabel()
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
    let cancelButton = UIButton()
    
    var pinLocationAnnotation = CustomPointAnnotation()
    
    var cancelButtonWidthAnchor:NSLayoutConstraint!
    var hidesCancelButton:Bool = true {
        didSet {
            self.cancelButtonWidthAnchor.constant = hidesCancelButton ? 0:72
            self.cancelButton.isHidden = hidesCancelButton
            self.view.layoutIfNeeded()
        }
    }
    
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
        
        
//        mapView.frame = CGRect(x: 0, y:82 , width: view.bounds.width, height: view.bounds.height-82)
//        searchBar.frame = CGRect(x: 0, y:30 , width: view.bounds.width, height: 52)
//        completionTableView.frame = CGRect(x: 0, y: 82, width: view.bounds.width, height: view.bounds.height - 82)
//        cancelButton
        
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
        mapView.delegate = presenter
        
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
        view.addSubview(cancelButton)
        
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
    
    @objc func zoomInButtonTapped() {
        let span = mapView.region.span
        let newSpan = MKCoordinateSpan(latitudeDelta: span.latitudeDelta*5/3, longitudeDelta: span.longitudeDelta*5/3)
        
        self.mapView.region = MKCoordinateRegion(center: mapView.region.center, span: newSpan)

        
    }
    
    @objc func zoomOutButtonTapped() {
        print ("zoom out")
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

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        if searchText.count >= 3 {
            
            self.completionPresenter.configureSearchCompleterRegion()
            self.completionPresenter.completer.queryFragment = searchText
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print (self.mapView.centerCoordinate)
        self.completionTableView.isHidden = true
        var keyword = searchBar.text ?? ""
        keyword = keyword.trimmingCharacters(in: .whitespaces)
        if keyword.count <= 2 {return}
        self.presenter.search(keyword: keyword)
        
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print ("textdidBeginEditing")
        self.hidesCancelButton = false
        view.layoutIfNeeded()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.hidesCancelButton = true
        view.layoutIfNeeded()
    }
    
}

extension ViewController:DirectionModuleToVCDelegate{
    func updateDirectionLabel(distance: String, directionText: String) {
        
    }
    
    func startDirection(distance: String, directionText: String) {
        
    }
    
    func directionModuleWarning(text: String) {
        self.presentAlert(text: text)
    }
    
    func updateDirectionLabel(text: String) {
        directHeader.text = text
    }
    
    func startDirection(text: String) {
        //direction module direction started,
        //add directHeader and configure direction Text
        view.addSubview(directHeader)
        directHeader.frame = CGRect(x: 0, y: 30, width: view.bounds.width, height: 88)
        directHeader.text = text
        directHeader.backgroundColor = .systemBackground
        directHeader.numberOfLines = 0
        directHeader.font = .systemFont(ofSize: 19)
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
        
        cancelButton.backgroundColor = .systemBackground
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(hideTableView), for: .touchUpInside)
        
        userTrackingButton.backgroundColor = .systemBackground
    }
    
    func addConstraints() {
        cancelButton.isHidden = true
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cancelButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        cancelButtonWidthAnchor = cancelButton.widthAnchor.constraint(equalToConstant: 0)
        cancelButtonWidthAnchor.isActive = true
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 52).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        
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


