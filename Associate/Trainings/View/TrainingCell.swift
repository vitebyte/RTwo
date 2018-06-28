//
//  TrainingCell.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 27/03/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit
import SDWebImage

class TrainingCell: UITableViewCell {

    //MARK: Variables
    var percentageCompleted: Int!

    var counter: Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            // let animated = counter != 0
            self.progressCompleted.setProgress(fractionalProgress, animated: false)
            self.percentageCompletedLabel.text = ("\(counter)%")
            self.percentageCompletedLabel.attributedText = UILabel.addTextSpacing(textString: self.percentageCompletedLabel.text!, spaceValue: 0.8)
        }
    }

    // MARK: - IBOutlets
    @IBOutlet weak var trainingsImageView: UIImageView!
    @IBOutlet weak var progressCompleted: UIProgressView!
    @IBOutlet weak var trainingTitleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var percentageCompletedLabel: UILabel!

    // MARK: - view life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - setup cell data
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func getPercentageCompleted(percentage: Int) {
        counter = percentage
    }

    // MARK: - Loading Data to Cell
    func setTrainingDataInCell(_ trainingObj: Training) {

        getPercentageCompleted(percentage: trainingObj.completedPer!)

        trainingTitleLabel.text = trainingObj.trainingTitle
        trainingTitleLabel.attributedText = UILabel.addTextSpacing(textString: trainingObj.trainingTitle!, spaceValue: 0.9)

        statusLabel.text = Helper.statusForTraining(status: trainingObj.status!)
        statusLabel.attributedText = UILabel.addTextSpacing(textString: statusLabel.text!, spaceValue: 0.8)

        let imagUrl: String = Constants.ImageUrl.SmallImage + trainingObj.imageUrl!
        trainingsImageView.sd_setShowActivityIndicatorView(true)
        trainingsImageView.sd_setIndicatorStyle(.gray)
        trainingsImageView.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder"), options: .retryFailed, completed: { _, _, _, _ in
            self.trainingsImageView.sd_setShowActivityIndicatorView(false)
        })
    }
}
