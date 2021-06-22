//
//  FirstInfoCell.swift
//  googleMapz
//
//  Created by Macbook on 6/13/21.
//

import Foundation
import UIKit
class SecondInfoCell:UITableViewCell {
    static let identifier = "SecondInfoCell"
    var delegate: SecondInfoCellDelegate?
    let button = UIButton()
    var cellData:SecondInfoCellData? {
        didSet {
            button.setTitle("Direction/n\(cellData?.timeToDestination ?? "default") minutes \(cellData?.modeOfTransport ?? "default")", for: .normal)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: SecondInfoCell.identifier)
        setupView()
        selectionStyle = .none
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpOutside)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4).isActive = true
        
        button.setTitle("Direction", for: .normal)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
    }
    
    @objc func buttonDidTap() {
        print ("secondINfoCell buttonDIdTap")
        self.delegate?.buttonDidTap()
    }
}

protocol SecondInfoCellDelegate {
    func buttonDidTap()
}

struct SecondInfoCellData {
    var timeToDestination:String     //route.expectedTravelTime
    var modeOfTransport:String
}
