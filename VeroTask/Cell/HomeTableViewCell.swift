//
//  HomeTableViewCell.swift
//  VeroTask
//
//  Created by Yigit Ozdamar on 24.03.2023.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var taskLabel: UILabel!
    
    @IBOutlet weak var descriptionsLabel: UILabel!
    
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   

}


