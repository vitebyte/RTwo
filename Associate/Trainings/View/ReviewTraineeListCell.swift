//
//  ReviewTraineeListCell.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 09/05/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

protocol ReviewTraineeListCellDelegate {
    func cellButtonAction(_ isApprove: Bool, _ indexPath: IndexPath)
}

class ReviewTraineeListCell: UITableViewCell {
    
    // MARK: - Variables
    var percentageCompleted: Int!
    var indexPathSelected: IndexPath?
    var delegate: ReviewTraineeListCellDelegate?

    var counter: Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            // let animated = counter != 0
            self.trainingProgressView.setProgress(fractionalProgress, animated: false)
            self.percentageLabel.text = ("\(counter)%")
            self.percentageLabel.attributedText = UILabel.addTextSpacing(textString: self.percentageLabel.text!, spaceValue: 0.8)
        }
    }

    // MARK: - IBOutlets
    @IBOutlet weak var trainingImageView: UIImageView!
    @IBOutlet weak var trainingNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var trainingProgressView: UIProgressView!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!

    // MARK: - View life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - Setup cell data
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func getPercentageCompleted(percentage: Int) {
        counter = percentage
    }

    func setButtonApperence(_ button: UIButton) {
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        button.layer.shadowRadius = 12.0
        button.layer.shadowColor = UIColor.init(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        button.setBackgroundColor(color: UIColor.white, forState: .normal)
        button.layer.cornerRadius = 2.0
    }

    // MARK: - Loading Data to Cell
    func setAssociateTrainingDataInCell(_ trainingObj: Training, withIndexPath indexPath: IndexPath) {

        indexPathSelected = indexPath
        getPercentageCompleted(percentage: trainingObj.completedPer!)

        trainingNameLabel.text = trainingObj.trainingTitle
        trainingNameLabel.attributedText = UILabel.addTextSpacing(textString: trainingObj.trainingTitle!, spaceValue: 0.9)

        statusLabel.text = Helper.statusForTraining(status: trainingObj.status!)
        statusLabel.attributedText = UILabel.addTextSpacing(textString: statusLabel.text!, spaceValue: 0.8)

        let imagUrl: String = Constants.ImageUrl.SmallImage + trainingObj.imageUrl!
        trainingImageView.sd_setShowActivityIndicatorView(true)
        trainingImageView.sd_setIndicatorStyle(.gray)
        trainingImageView.sd_setImage(with: URL(string: imagUrl), placeholderImage: UIImage(named: "placeholder"), options: .retryFailed, completed: { _, _, _, _ in
            self.trainingImageView.sd_setShowActivityIndicatorView(false)
        })

        setButtonApperence(approveButton)
        setButtonApperence(rejectButton)
    }

    // MARK: - Cell Button Actions
    @IBAction func rejectButtonAction(_: UIButton) {
        delegate?.cellButtonAction(false, indexPathSelected!)
    }

    @IBAction func approveButtonAction(_: UIButton) {
        delegate?.cellButtonAction(true, indexPathSelected!)
    }
}
