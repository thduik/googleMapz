//
//  SixthInfoCell.swift
//  googleMapz
//
//  Created by Macbook on 6/13/21.
//

import Foundation
import UIKit

class SixthInfoCell:UITableViewCell {
    static let identifier = "SixthInfoCell"
    var delegate:SixthInfoCellDelegate?
    let button = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: SixthInfoCell.identifier)
        setupView()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        let callButton = CustomButton(buttonType: .callButton)
        let saveToButton = CustomButton(buttonType: .saveToButton)
        let shareButton = CustomButton(buttonType: .shareButton)
        let stackView = UIStackView(arrangedSubviews: [callButton, saveToButton, shareButton])
        
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.setTitle("Report an Issue", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 4).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4).isActive = true
//        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 76).isActive = true
        
        stackView.spacing = 4
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        callButton.backgroundColor = .gray
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        
        saveToButton.backgroundColor = .gray
        saveToButton.addTarget(self, action: #selector(saveToButtonTapped), for: .touchUpInside)
        
        shareButton.backgroundColor = .gray
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    @objc func callButtonTapped() {
        self.delegate?.callButtonTapped()
    }
    
    @objc func saveToButtonTapped() {
        self.delegate?.saveToButtontapped()
    }
    
    @objc func shareButtonTapped() {
        self.delegate?.shareButtonTapped()
    }
    
    @objc func reportIssueButtonTapped() {
        self.delegate?.reportIssueButtonTapped()
    }
    
}

protocol SixthInfoCellDelegate {
    func callButtonTapped()
    func saveToButtontapped()
    func shareButtonTapped()
    func reportIssueButtonTapped()
}
