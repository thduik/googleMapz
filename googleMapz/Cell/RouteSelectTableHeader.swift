//
//  RouteSelectTableHeader.swift
//  googleMapz
//
//  Created by Macbook on 6/26/21.
//

import UIKit

protocol RouteSelectTableHeaderDelegate {
    func didTapCancelButton()
}

class RouteSelectTableHeader: UITableViewHeaderFooterView {
    
    let topLabel = UILabel()
    let bottomLabel = UILabel()
    let cancelButton = UIButton()
    
    var delegate:RouteSelectTableHeaderDelegate?
    static let identifier = "RouteSelectTableHeader"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        cancelButton.setTitle("X", for: .normal)
        cancelButton.backgroundColor = .red
        cancelButton.layer.cornerRadius = 10
        
        addSubview(topLabel)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        topLabel.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: 8).isActive = true
        topLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        topLabel.heightAnchor.constraint(equalTo:heightAnchor, multiplier: 0.44).isActive = true
        topLabel.numberOfLines = 0
        topLabel.font = .boldSystemFont(ofSize: 23)
        
        addSubview(bottomLabel)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 4).isActive = true
        bottomLabel.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: 8).isActive = true
        bottomLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        bottomLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4).isActive = true
        bottomLabel.numberOfLines = 0
        bottomLabel.font = .systemFont(ofSize: 21)
        
    }
    
   
    
    func configureText(destination:String, origin:String) {
        self.topLabel.text = "To " + destination
        self.bottomLabel.text = "From " + origin
    }
}
