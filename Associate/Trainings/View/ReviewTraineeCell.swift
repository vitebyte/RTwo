//
//  ReviewTraineeCell.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 09/05/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

class ReviewTraineeCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var traineeImageView: UIImageView!
    @IBOutlet weak var traineeNameLabel: UILabel!

    // MARK: - view life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        showCircularTraineeImageView()
    }

    // MARK: - setup data
    func showCircularTraineeImageView() {
        traineeImageView.layoutIfNeeded()
        traineeImageView.layer.cornerRadius = traineeImageView.frame.size.width / 2
        traineeImageView.layer.masksToBounds = true
        traineeImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setDataOfTrainees(user: User) {
        traineeNameLabel.text = user.userName
        let imagUrl: String = Constants.ImageUrl.SmallImage + user.profileImg!
        traineeImageView.sd_setShowActivityIndicatorView(true)
        traineeImageView.sd_setIndicatorStyle(.gray)
        traineeImageView.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "defaultPic"), options: .retryFailed, completed: { _, _, _, _ in
            self.traineeImageView.sd_setShowActivityIndicatorView(false)
        })
    }
}
