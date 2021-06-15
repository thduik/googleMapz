//
//  FourthInfoCell.swift
//  googleMapz
//
//  Created by Macbook on 6/13/21.
//

import Foundation
import UIKit

class FourthInfoCell:UITableViewCell {
    static let identifier = "FourthInfoCell"
    let lowerLabel = UILabel()
    var phoneNumber:String = "090829282828"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: FourthInfoCell.identifier)
        setupView()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(lowerLabel)
        lowerLabel.translatesAutoresizingMaskIntoConstraints = false
        lowerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        lowerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        lowerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4).isActive = true
        lowerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4).isActive = true
        lowerLabel.textAlignment = .left
        lowerLabel.font = .boldSystemFont(ofSize: 18)
        lowerLabel.text = self.phoneNumber
    }
}

