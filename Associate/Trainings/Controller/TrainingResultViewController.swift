//
//  TrainingResultViewController.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 12/04/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//  // 9971638369 Deepak

import UIKit

class TrainingResultViewController: BaseViewController {

    // MARK: - Variables
    var trainingInfo: Training?

    fileprivate var attemptRemaining: String! = "0"
    public var userSelectedAnswer: NSMutableArray = NSMutableArray()
    public var questionsArray = [Question]()
    public var isComeFromTrainimg: Bool = false

    // MARK: - IBOutlets
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var trainingTitleLabel: UILabel!
    @IBOutlet var navigationView: UIView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var showPercentView: UIView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var correctQuesLabel: UILabel!
    @IBOutlet weak var wellDoneLabel: UILabel!
    @IBOutlet weak var completeLabel: UILabel!

    // MARK: - View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        doInitialSetup()
        navigationItem.setHidesBackButton(true, animated: false)

        if isComeFromTrainimg { // show result percentage
            tryAgainButton.isHidden = true
            if let result: Int = self.trainingInfo?.quizResult {
                percentLabel.text = String(result) + "%"
            } else {
                percentLabel.text = "NA"
            }
        } else {
            // api call
            sendResultToServer()
        }
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        localizeStrings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Showing number of attempts
        if !isComeFromTrainimg {
            let attempts = Int(CoreDataManager.trainingAttemptsLeft(forTraining: (trainingInfo?.trainingId)!))
            attemptRemaining = "\(attempts)"
            self.setAttributedStringOnTryAgainButtonWith(attempts: attemptRemaining)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Helper Methods
    func doInitialSetup() {

        super.navigationBarAppearanceWhite(navController: navigationController!)
        showPercentView.layer.cornerRadius = 2.0

        navigationItem.titleView = setTitle(title: (trainingInfo?.trainingTitle)!, subtitle: (trainingInfo?.categoryName)!)
    }

    func localizeStrings() {
        finishButton.setTitle(LocalizedString.shared.buttonFinishTitle, for: .normal)
        correctQuesLabel.text = LocalizedString.shared.correctQuestionString
        wellDoneLabel.text = LocalizedString.shared.wellDoneString
        completeLabel.text = LocalizedString.shared.completeString
    }

    func setTitle(title: String, subtitle: String) -> UIView {
        trainingTitleLabel.text = title
        categoryNameLabel.text = subtitle
        return navigationView
    }

    func setAttributedStringOnTryAgainButtonWith(attempts: String) {
        let yourAttributes = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.gothamLight(15.0)]
        let yourOtherAttributes = [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont.gothamMedium(15.0)]

        let attemptRemainingText = NSMutableAttributedString(string: "\(attempts) " + LocalizedString.shared.attemptRemainingString + " ", attributes: yourAttributes)
        let tryAgainText = NSMutableAttributedString(string: LocalizedString.shared.tryAgainString, attributes: yourOtherAttributes)
        let combination = NSMutableAttributedString()
        combination.append(attemptRemainingText)
        combination.append(tryAgainText)
        tryAgainButton.setAttributedTitle(combination, for: .normal)
    }

    func popToRootView() {
        Helper.hideLoader()
        _ = navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Button Action
    @IBAction func finishButtonAction(_: UIButton) {

        popToRootView()
    }

    @IBAction func tryAgainButtonAction(_: UIButton) {
        // If reattempts > 0
        CoreDataManager.reattemptQuiz(for: trainingInfo!)

        Helper.showLoader()
        delay(delay: 0.5) {
            CoreDataManager.updateTrainingStatus(self.trainingInfo!, to: TrainingStatus.InProgress.hashValue)
        }
        delay(delay: 0.5) {
            self.popToRootView()
        }
    }

    func delay(delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
}

// MARK: - Result Calculation
extension TrainingResultViewController {

    func sendResultToServer() {
        // syncTrainingResult
        let ansArray: NSMutableArray = NSMutableArray()
        let quizList = CoreDataManager.loadQuestionInfo(forTraining: (trainingInfo?.trainingId)!)
        for questionInfo in quizList {
            let ansDict = [Constants.RESULTKEY.QUESTIONID: "\(questionInfo.id)", Constants.RESULTKEY.ANSWERID: "\(questionInfo.selectedAnswer)"]
            ansArray.add(ansDict)
        }

        Helper.showLoader()
        Training.syncTrainingResult(ansArray as [AnyObject], trainingId: (trainingInfo?.trainingId)!) { success, _ in
            Helper.hideLoader()
            if success {

                // reduce number of attempts
                CoreDataManager.finishQuiz(for: self.trainingInfo!)

                CoreDataManager.updateTrainingStatus(self.trainingInfo!, to: TrainingStatus.Completed.hashValue)

                // show result of the quiz to the user
                self.showResult()
            } else {
                self.showAlertViewWithMessage(LocalizedString.shared.FAILURE_TITLE, message: LocalizedString.shared.QUIZ_ERROR,true)
            }
        }
    }

    // TODO: Fix below logic of result calculation
    func showResult() {

        // find user selected answers
        var answer: [Int]? = [Int]()
        let quizList = CoreDataManager.loadQuestionInfo(forTraining: (trainingInfo?.trainingId)!)
        for questionInfo in quizList {
            answer?.append(Int(questionInfo.selectedAnswer))
            userSelectedAnswer.add(questionInfo.selectedAnswer)
        }

        // find actual correct answers
        var correctAnswersCount: Int = 0
        for tempDictionary in questionsArray {
            let optionValues = tempDictionary.options?.filter { $0.answerFlag == true }
            let correntAnswerId: Int = Int((optionValues?.first?.answerId)!)
            if (answer?.contains(correntAnswerId))! {
                correctAnswersCount = correctAnswersCount + 1
            }
        }

        let totalPersentage = (Float(correctAnswersCount) / Float(questionsArray.count)) * 100
        let persentage = String(format: "%.f", totalPersentage)
        percentLabel.text = persentage + "%"

        tryAgainButton.isHidden = false
        delay(delay: 0.5) {
            // Get number of attemplts from DB and show on button
            let attemptsLeft = Int(CoreDataManager.trainingAttemptsLeft(forTraining: (self.trainingInfo?.trainingId)!))
            self.attemptRemaining = "\(attemptsLeft)"
            self.setAttributedStringOnTryAgainButtonWith(attempts: self.attemptRemaining)
            if attemptsLeft == 0 {
                self.tryAgainButton.isHidden = true
            } else {
                self.tryAgainButton.isHidden = false
            }
            // self.tryAgainButton.isHidden = attemptsLeft == 0 ? true : false
        }
    }
}
