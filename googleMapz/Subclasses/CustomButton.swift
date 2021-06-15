//
//  CustomButton.swift
//  googleMapz
//
//  Created by Macbook on 6/14/21.
//

import Foundation
import UIKit
class CustomButton: UIButton {

    var myValue: Int
    let upperImageView = UIImageView()
    let textLabel = UILabel()
    private var buttonTypeName:ButtonType
    
    enum ButtonType {
        case callButton
        case saveToButton
        case shareButton
    }
    
    init(value: Int = 0, buttonType:ButtonType) {
        // set myValue before super.init is called
        self.myValue = value
        self.buttonTypeName = buttonType
        super.init(frame: .zero)

        // set other operations after super.init, if required
        backgroundColor = .red
        setupView()
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = .gray
        
        addSubview(upperImageView)
        upperImageView.translatesAutoresizingMaskIntoConstraints = false
        upperImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4).isActive = true
        upperImageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        upperImageView.widthAnchor.constraint(equalToConstant: 52).isActive = true
        upperImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.66).isActive = true
        
        
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.topAnchor.constraint(equalTo: upperImageView.bottomAnchor, constant: 0).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4).isActive = true
        textLabel.textAlignment = .center
        textLabel.textColor = .blue
        
        layer.cornerRadius = 15
        layer.masksToBounds = true
    }
    
    private func configureButton() {
        switch self.buttonTypeName {
        case .callButton:
            self.upperImageView.image = UIImage(systemName: "phone.fill")!
            self.textLabel.text = "Call"
        case .saveToButton:
            self.upperImageView.image = UIImage(systemName: "plus.square.fill")!
            self.textLabel.text = "Save to..."
        case .shareButton:
            self.upperImageView.image = UIImage(systemName: "arrow.up.square")!
            self.textLabel.text = "Share"
        }
    }
}
