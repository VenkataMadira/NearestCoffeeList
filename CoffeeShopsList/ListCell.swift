//
//  ListCell.swift
//  CoffeeShopsList
//
//  Created by Venkat Madira on 25/01/2021.
//


import UIKit

class ListCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var checkinsLabel: UILabel?
    @IBOutlet weak var categoryLabel: UILabel?
    
    var venue: Venue? {
        didSet {
            
            if let title = venue?.name {
                self.titleLabel?.text = "\(title)"
            }
            
            if let checkins = venue?.checkins.description {
                self.checkinsLabel?.text = "No. of Checkins: \(checkins)"
            }
            
            if let category = venue?.categoryName {
                self.categoryLabel?.text = "\(category)"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

