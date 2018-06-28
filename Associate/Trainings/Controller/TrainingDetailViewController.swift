//
//  TrainingDetailViewController.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 28/03/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TrainingDetailViewController: BaseViewController {
    
    //MARK: - Variables
    public var trainingInfo: Training?

    // MARK: - IBOutlets
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var detailtextView: UITextView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var trainingTitleLabel: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var trainingStatusLabel: UILabel!

    //MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // super.addBlackBackBarButton()
        super.addLeftBarButton(withImageName: Constants.BarButtonItemImage.BackArrowBlackColor)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        doInitialSetup()
    }

    // MARK: - Helper Method
    func doInitialSetup() {
        super.navigationBarAppearanceWhite(navController: navigationController!)
        navigationItem.titleView = setTitle(title: (trainingInfo?.trainingTitle)!, subtitle: (trainingInfo?.categoryName!)!)

        // self.navigationItem.title = trainingInfo?.trainingTitle!

        localizeStrings()
        setAttributedTextToLabelWithHTMLString(textString: (trainingInfo?.trainingContent)!)
    }

    func localizeStrings() {
        getStartedButton.setTitle(LocalizedString.shared.getStartedTitle, for: .normal)
        trainingStatusLabel.text = LocalizedString.shared.startTitle + " \(trainingInfo!.trainingTitle!)"
    }

    func setAttributedTextToLabelWithHTMLString(textString: String) {
        detailtextView.from(htmlString: textString)
        detailtextView.contentOffset.y = 0.0
    }

    // MARK: Navigation Bar View With Subtitle
    func setTitle(title: String, subtitle: String) -> UIView {
        trainingTitleLabel.text = title
        categoryNameLabel.text = subtitle
        return navigationView
    }

    func moveToTrainingQuestionsViewController() {
        let storyBoard: UIStoryboard = UIStoryboard.trainingStoryboard()
        let trainingVideoVC = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.TrainingVideoIdentifier) as! TrainingVideoViewController
        trainingVideoVC.trainingInfo = trainingInfo!
        navigationController?.pushViewController(trainingVideoVC, animated: true)
    }

    // MARK: - Button Actions
    @IBAction func getStartedAction(_: Any) {
        moveToTrainingQuestionsViewController()
    }
    
    override func leftButtonPressed(_: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }

}
