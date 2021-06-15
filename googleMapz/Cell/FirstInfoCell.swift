//
//  FirstInfoCell.swift
//  googleMapz
//
//  Created by Macbook on 6/13/21.
//

import Foundation
import UIKit

protocol  FirstInfoCellDelegate {
    func directionButtonDidTap()
}

class FirstInfoCell:UITableViewCell {
    static let identifier = "FirstInfoCell"
    let upperLabel = UILabel()
    let lowerLabel = UILabel()
    var placeName:String = "defaultPlace"
    var distance:String = "800m"
    var delegate:FirstInfoCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: FirstInfoCell.identifier)
        selectionStyle = .none
        setupView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        addSubview(upperLabel)
        upperLabel.translatesAutoresizingMaskIntoConstraints = false
        upperLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        upperLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        upperLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        upperLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.45).isActive = true
        upperLabel.textAlignment = .left
        upperLabel.font = .boldSystemFont(ofSize: 18)
        upperLabel.text = self.placeName
        
        addSubview(lowerLabel)
        lowerLabel.translatesAutoresizingMaskIntoConstraints = false
        lowerLabel.topAnchor.constraint(equalTo: upperLabel.bottomAnchor, constant: 0).isActive = true
        lowerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        lowerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4).isActive = true
        lowerLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.45).isActive = true
        lowerLabel.textAlignment = .left
        lowerLabel.font = .boldSystemFont(ofSize: 18)
        lowerLabel.text = self.distance
    }
    
    func configureText(upperText:String, lowerText:String) {
        upperLabel.text = upperText
        lowerLabel.text = lowerText
    }
    
    
}


