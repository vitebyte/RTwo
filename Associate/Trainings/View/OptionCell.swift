//
//  OptionCell.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 03/04/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

class OptionCell: UITableViewCell {

    // MARK: - IBOUTLETS
    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var optionsLabel: UILabel!
    @IBOutlet weak var optionalView: UIView!

    //MARK: - view life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        optionalView.layer.shadowOpacity = 0.1
        optionalView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0) // Here you control x and y
        optionalView.layer.shadowRadius = 7.0 // Here your control your blur
        optionalView.layer.shadowColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1).cgColor
        optionalView.layer.cornerRadius = 2.0
        tickImageView.isHidden = true
    }

    //MARK: - setup cell data
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            tickImageView.isHidden = false
            optionsLabel.font = UIFont.gothamMedium(15)

        } else {
            tickImageView.isHidden = true
            optionsLabel.font = UIFont.gothamLight(15)
        }
    }

    // MARK: - Loading Data to Cell

    func setAnswerDataInCell(_ optionObj: Options) {
        optionsLabel.text = optionObj.answer
    }
}
