//
//  Header.swift
//  googleMapz
//
//  Created by Macbook on 6/15/21.
//

import Foundation
import UIKit

class CustomHeader: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
