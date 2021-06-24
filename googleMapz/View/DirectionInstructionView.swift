//
//  DirectionInstructionView.swift
//  googleMapz
//
//  Created by Macbook on 6/21/21.
//

import UIKit
import MapKit

class DirectionInstructionView: UIView {

    private let distanceLabel = UILabel()
    private let instructionLabel = UILabel()
    private let instructionImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .systemTeal
        
        addSubview(instructionImageView)
        instructionImageView.translatesAutoresizingMaskIntoConstraints = false
        instructionImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        instructionImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        instructionImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        instructionImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.15).isActive = true
        
        addSubview(distanceLabel)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.leadingAnchor.constraint(equalTo: instructionImageView.trailingAnchor, constant: 12).isActive = true
        distanceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32).isActive = true
        distanceLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        distanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        distanceLabel.font = .boldSystemFont(ofSize: 23)
        distanceLabel.numberOfLines = 0
        
        
        addSubview(instructionLabel)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.leadingAnchor.constraint(equalTo: instructionImageView.trailingAnchor, constant: 12).isActive = true
        instructionLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 8).isActive = true
        instructionLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        instructionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        instructionLabel.font = .systemFont(ofSize: 21)
        instructionLabel.numberOfLines = 0
    }
    
    public func updateLabels(distance:String, instructions:String) {
        distanceLabel.text = "In " + String(distance.prefix(6)) + "m"
        instructionLabel.text = instructions
    }
    
    
}
