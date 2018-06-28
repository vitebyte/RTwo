//
//  FeedOptionsCell.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 19/05/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

class FeedOptionsCell: UITableViewCell {

    //MARK: - Outlets
    @IBOutlet weak var alphabeticalListLabel: UILabel!
    @IBOutlet weak var optionsLabel: UILabel!
    
    //MARK: Cell life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
