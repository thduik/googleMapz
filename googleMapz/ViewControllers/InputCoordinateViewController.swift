//
//  InputCoordinateViewController.swift
//  googleMapz
//
//  Created by Macbook on 6/18/21.
//

import UIKit
import MapKit
import CoreLocation

protocol InputCoordinateViewControllerDelegate {
    func didFinishInputCoordinate(coord:CLLocationCoordinate2D, name:String)
}

class InputCoordinateViewController: UIViewController {
    
    var delegate:InputCoordinateViewControllerDelegate?
    
    @IBOutlet weak var LatTextField: UITextField!
    @IBOutlet weak var lonTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func DoneButtonPressed(_ sender: UIButton) {
        guard let latString = LatTextField.text else {return}
        guard let lonString = lonTextField.text else {return}
        let name = nameTextField.text ?? "default Name"
        
        guard let latDegree = CLLocationDegrees(latString) else {return}
        guard let lonDegree = CLLocationDegrees(lonString) else {return}
        
        let coords = CLLocationCoordinate2D(latitude: latDegree, longitude: lonDegree)
        
        self.delegate?.didFinishInputCoordinate(coord: coords, name: name)
        self.dismiss(animated: true, completion: nil)
    }
}
