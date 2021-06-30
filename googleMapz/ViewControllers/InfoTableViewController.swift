//
//  InfoTableViewController.swift
//  googleMapz
//
//  Created by Macbook on 6/13/21.
//

import UIKit
import MapKit

protocol InfoTableViewDelegate {
    func didTapDirectionButton(destinationName:String, destinationCoordinate:CLLocationCoordinate2D)
}

class InfoTableViewController: UITableViewController {
    var placeInfo:PlaceInfoStruct
    var delegate:InfoTableViewDelegate?
    var completionTableVC = CompletionTableViewController()
    var destinationCoordinate:CLLocationCoordinate2D
    
    init(style: UITableView.Style, placeData:PlaceInfoStruct) {
        placeInfo = placeData
        self.destinationCoordinate = placeData.coordinate
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var showPhoneCell:Bool = false
    var showUrlCell:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FirstInfoCell.self, forCellReuseIdentifier: FirstInfoCell.identifier)
        tableView.register(SecondInfoCell.self, forCellReuseIdentifier: SecondInfoCell.identifier)
        tableView.register(ThirdInfoCell.self, forCellReuseIdentifier: ThirdInfoCell.identifier)
        tableView.register(FourthInfoCell.self, forCellReuseIdentifier: FourthInfoCell.identifier)
        tableView.register(SixthInfoCell.self, forCellReuseIdentifier: SixthInfoCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        if let phoneNumber = self.placeInfo.phoneNumber {
            self.showPhoneCell = true
        }
        
        if let websiteUrl = self.placeInfo.url {
            self.showUrlCell = true
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 2 //direction
        case 1:
            return 1 //address
        case 2:
            return 1 //phone
        case 3:
            return 1 //website url
        case 4:
            return 1 //5+6 = 1 big cell (SixthCell)
        case 5:
            return 4 //7 - Add To Favorites etc
        default:
            return 0
            
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: FirstInfoCell.identifier, for: indexPath) as! FirstInfoCell
                var text:String = self.placeInfo.name
                
                cell.configureText(upperText: self.placeInfo.name, lowerText: self.placeInfo.categoryName ?? "")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: SecondInfoCell.identifier, for: indexPath) as! SecondInfoCell
                let secondCellGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectSecondCellButton))
                secondCellGesture.delegate = self
                cell.button.addGestureRecognizer(secondCellGesture)
                cell.delegate = self
                cell.bringSubviewToFront(cell.button)
                return cell
            default:
                break
            }
        case 1: //third cell - address
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = self.placeInfo.address ?? "defaultAddress"
            cell.textLabel?.numberOfLines = 0
            cell.selectionStyle = .none
            return cell
        case 2: //4 cell - phone
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = self.placeInfo.phoneNumber ?? "defaultNumber"
            self.showPhoneCell = true
            cell.selectionStyle = .none
            return cell
        case 3: //4.1 cell - website URL
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = self.placeInfo.url?.relativeString ?? "defaultUrl"
            self.showUrlCell = true
            cell.selectionStyle = .none
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: SixthInfoCell.identifier, for: indexPath) as! SixthInfoCell
            
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Add to Favourites"
            cell.selectionStyle = .none
            self.showPhoneCell = true
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "ERROR CELL BITCH"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "ERROR CELL BITCH"
        return cell
    }
    
    @objc func didSelectSecondCellButton() {
        print ("did select second cell")
        self.delegate?.didTapDirectionButton(destinationName: self.placeInfo.name, destinationCoordinate: self.destinationCoordinate)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return self.placeInfo.name
        case 1:
            return "Address"
        case 2:
            return self.showPhoneCell ? "Phone":nil
        case 3:
            return self.showUrlCell ? "Website":nil
        case 4:
            return nil
        case 5:
            return nil
        default:
            return nil
        }
        return nil
    }
    

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 76
        case 1:
            return 112
        case 2:
            return self.showPhoneCell ? 32 : 0
        case 3:
            return self.showUrlCell ? 32 : 0
        case 4:
            return 156
        case 5:
            return 76
        default:
            return 0
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = .systemBackground
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = .systemBackground
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " "
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0 //30
    }
}

extension InfoTableViewController:UIGestureRecognizerDelegate {
    
}


extension InfoTableViewController:SixthInfoCellDelegate, SecondInfoCellDelegate {
    func buttonDidTap() {
        self.delegate?.didTapDirectionButton(destinationName: self.placeInfo.name, destinationCoordinate: self.destinationCoordinate)
        self.dismiss(animated: true, completion: nil)
    }
    
    func callButtonTapped() {
        
    }
    
    func saveToButtontapped() {
        
    }
    
    func shareButtonTapped() {
        
    }
    
    func reportIssueButtonTapped() {
        
    }
    
    
}



