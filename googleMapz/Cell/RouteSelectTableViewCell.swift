//
//  RouteSelectTableViewCell.swift
//  googleMapz
//
//  Created by Macbook on 6/24/21.
//

import UIKit

class RouteSelectTableViewCell: UITableViewCell {
    let topLabel = UILabel()
    let bottomLabel = UILabel()
    let goButton = UIButton()
    
    static let identifier = "RouteSelectTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        
        addSubview(goButton)
        goButton.translatesAutoresizingMaskIntoConstraints = false
        goButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        goButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        goButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        goButton.widthAnchor.constraint(equalToConstant: 68).isActive = true
        goButton.setTitle("GO", for: .normal)
        goButton.setTitleColor(.white, for: .normal)
        goButton.backgroundColor = .green
        
        addSubview(topLabel)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.trailingAnchor.constraint(equalTo: goButton.leadingAnchor, constant: 8).isActive = true
        topLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topLabel.leadingAnchor.constraint(equalTo:leadingAnchor).isActive = true
        topLabel.heightAnchor.constraint(equalToConstant: 42).isActive = true
        topLabel.font = .boldSystemFont(ofSize: 23)
        topLabel.numberOfLines = 0
        
        addSubview(bottomLabel)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.trailingAnchor.constraint(equalTo: goButton.leadingAnchor, constant: 8).isActive = true
        bottomLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bottomLabel.leadingAnchor.constraint(equalTo:leadingAnchor).isActive = true
        bottomLabel.bottomAnchor.constraint(equalTo:bottomAnchor).isActive = true
        bottomLabel.font = .systemFont(ofSize: 20)
        bottomLabel.numberOfLines = 0
        
    }
}
