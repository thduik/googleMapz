//
//  RouteSelectXIBTableViewCell.swift
//  googleMapz
//
//  Created by Macbook on 6/26/21.
//

import UIKit

protocol RouteSelectXIBTableViewCellDelegate {
    func goButtonDidTap(indexPathRow:Int)
}

class RouteSelectXIBTableViewCell: UITableViewCell {
    var indexPathRow:Int = 0
    var delegate:RouteSelectXIBTableViewCellDelegate?
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    static let identifier = "RouteSelectXIBTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        topLabel.numberOfLines = 0
        bottomLabel.numberOfLines = 0
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureText(roadName:String, travelTime:Double, advisoryNotices:[String]) {
        let minutes = Int(travelTime / 60)
        var time:String = "\(minutes) min"
        
        if minutes > 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            time = "\(hours) hr \(mins) min"
        }
        
        self.topLabel.text = time
        self.bottomLabel.text = String(roadName) + ". " + roadName + "\n" +  advisoryNotices.joined(separator: "; ")
        
    }
    
    @IBAction func GoButtonTouched(_ sender: UIButton) {
        self.delegate?.goButtonDidTap(indexPathRow: self.indexPathRow)
    }
}
