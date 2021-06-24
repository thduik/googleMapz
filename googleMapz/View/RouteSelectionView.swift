//
//  RouteSelectionView.swift
//  googleMapz
//
//  Created by Macbook on 6/23/21.
//

//import Foundation
//import UIKit
//import MapKit
//
//struct RouteTableViewData {
//    
//}
//
//class RouteSelectionView:UIView {
//    let topLabel: RouteSelectTopLabel
//    let tableView = UITableView()
//    var topLabelAttrText:String = ""
//    
//    init(destination:String, origin:String, routeData:[RouteTableViewData]) {
//        self.topLabel = RouteSelectTopLabel(destination: destination, origin: origin)
//        self.topLabelAttrText = self.topLabel.text ?? "From \(destination)"
//        super.init(frame: CGRect.zero)
//        setupView()
//    }
//    
//    func setupView() {
//        self.setupAttributeStrings()
//    }
//    
//    func setupAttributeStrings() {
//        let text = "Please agree for Terms & Conditions."
//        topLabel.text = text
//        self.topLabel.textColor =  UIColor.white
//        let underlineAttriString = NSMutableAttributedString(string: text)
//        let range1 = (text as NSString).range(of: "Terms & Conditions.")
//             underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
//        underlineAttriString.addAttribute(NSAttributedString.Key.font, value:UIFont.systemFont(ofSize: 21), range: range1)
//        
//        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: range1)
//        topLabel.attributedText = underlineAttriString
//        topLabel.isUserInteractionEnabled = true
//        topLabel.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
//            
//    }
//    
//    @objc func  tapLabel(gesture: UITapGestureRecognizer) {
//        let termsRange = (self.topLabelAttrText as NSString).range(of: "Terms & Conditions")
//        // comment for now
//        //let privacyRange = (text as NSString).range(of: "Privacy Policy")
//
//        if gesture.didTapAttributedTextInLabel(label: topLabel, inRange: termsRange) {
//            print("Tapped terms")
//        }  else {
//            print("Tapped none")
//        }
//        }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    
//}
