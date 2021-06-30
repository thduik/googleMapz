//
//  File.swift
//  googleMapz
//
//  Created by Macbook on 6/22/21.
//

import Foundation
import UIKit

class DirectionFooterView:UIView {
    private let placeLabel = UILabel()
    private let timeLabel = UILabel()
    let endButton = UIButton()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .systemTeal
        
        
        
        addSubview(endButton)
        endButton.translatesAutoresizingMaskIntoConstraints = false
        endButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 12).isActive = true
        endButton.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        endButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        endButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.15).isActive = true
        endButton.backgroundColor = .red
        endButton.setTitle("End", for: .normal)
        endButton.setTitleColor(.white, for: .normal)
        
        addSubview(placeLabel)
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        placeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        placeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        placeLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4).isActive = true
        placeLabel.trailingAnchor.constraint(equalTo: endButton.leadingAnchor, constant: -12).isActive = true
        placeLabel.font = .boldSystemFont(ofSize: 23)
        placeLabel.numberOfLines = 0
        
        
        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        timeLabel.topAnchor.constraint(equalTo: placeLabel.bottomAnchor, constant: 8).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: endButton.leadingAnchor, constant: -12).isActive = true
        timeLabel.font = .systemFont(ofSize: 21)
        timeLabel.numberOfLines = 0
    }
    
    func configureLabels(withEsimatedTime travelTime:Double, placeName:String) {
        let minutes = Int(travelTime / 60)
        var time:String = "\(minutes) min"
        
        if minutes > 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            time = "\(hours) hr \(mins) min"
        }
        self.timeLabel.text = time
        self.placeLabel.text = placeName
    }
}
