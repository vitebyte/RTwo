//
//  TrainingQuestionsViewController.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 03/04/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

let questionsTableViewID = "questionsTableView"

class TrainingQuestionsViewController: UIViewController {

    // MARK: - Variables
    fileprivate var userSelectedAnswer: NSMutableArray = NSMutableArray()

    var questionsArray = [Question]()

    public let cellIdentifier = "QuestionsTraining"
    fileprivate let itemSpacing: CGFloat = 83.0
    public var trainingDetail: Training?
    public var userSelectedAnswerId: Int? = 0
    public var currentQuestion: Question!
    fileprivate var currentQuestionIndex: Int = 0
    fileprivate var selectedIndex: Int = 0
    fileprivate var counter: Int = 1 {
        didSet {
            let count = self.questionsArray.count
            let progresslvl: Float = Float(self.counter) / Float(self.questionsArray.count)
            self.progressView.setProgress(progresslvl, animated: true)
            self.currentQuesLabel.text = LocalizedString.shared.questionString + " \(counter)" + " " + LocalizedString.shared.ofString + " \(count)"
        }
    }

    // MARK: - IBOutlets
    @IBOutlet weak var currentQuesLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var questionsTableView: UITableView!
    @IBOutlet weak var finishLaterButton: UIButton!
    @IBOutlet weak var nextQuesButton: UIButton!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var quesNoLabel: UILabel!
    @IBOutlet weak var quesLabel: UILabel!
    @IBOutlet weak var subHeaderView: UIView!

    // MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true

        subHeaderView.layer.cornerRadius = 2.0
        subHeaderView.backgroundColor = UIColor.init(hexColorCode: Constants.ColorHexCodes.gallerySolidGray)
        currentQuesLabel.attributedText = UILabel.addTextSpacing(textString: currentQuesLabel.text!, spaceValue: 0.8)

        // check remember questions
        let questionsCompleted = CoreDataManager.questionsCompletedUpto(forTraining: (trainingDetail?.trainingId)!)
        currentQuestionIndex = Int(questionsCompleted)
        counter = currentQuestionIndex + 1
        if currentQuestionIndex == questionsArray.count {
            moveToTrainingResultController()
        } else {
            setUpQuestionInView(questionsArray[self.currentQuestionIndex])
        }

        quesLabel.accessibilityIdentifier = "quesLabel"
        questionsTableView.accessibilityIdentifier = questionsTableViewID
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        localizeStrings()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Localization
    func localizeStrings() {
        nextQuesButton.setTitle(LocalizedString.shared.nextQuestionString, for: .normal)
        let _: String = LocalizedString.shared.finishLaterString + " \(self.trainingDetail!.trainingTitle)"
        finishLaterButton.setTitle(LocalizedString.shared.finishLaterString, for: .normal)
    }

    // MARK: - Helpers
    func setUpQuestionInView(_ quesInfo: Question) {
        currentQuestion = quesInfo
        quesLabel.text = currentQuestion?.question
        quesNoLabel.text = LocalizedString.shared.questionString + " \(self.counter)"
        quesLabel.sizeToFit()
        alignQuestionCeter()
        questionsTableView.reloadData()
    }

    func alignQuestionCeter() {
        var point: CGPoint = quesLabel.center
        point.x = headerView.center.x
        quesLabel.center = point
    }

    func showCurrentQuestion() {
        if currentQuestionIndex < questionsArray.count - 1 {
            userSelectedAnswerId = 0
            currentQuestionIndex += 1
            counter += 1
            setUpQuestionInView(questionsArray[self.currentQuestionIndex])
            if counter == questionsArray.count {
                nextQuesButton.setTitle(LocalizedString.shared.buttonPresentedTitle, for: .normal)
            }
        } else {
            moveToTrainingResultController()
        }
    }

    func saveSelectedAnswer() {
        // save answer to coredata
        CoreDataManager.saveAnswer(userSelectedAnswerId!, for: currentQuestion)

        // keep selection save for server updation
        var ansDict: [String: Any] = [String: Any]()
        ansDict[Constants.RESULTKEY.QUESTIONID] = currentQuestion.questionId!
        ansDict[Constants.RESULTKEY.ANSWERID] = userSelectedAnswerId! as AnyObject
        userSelectedAnswer.add(ansDict)
    }

    // MARK: - Action
    @IBAction func finishButtonAction(_: Any) {
        
        if self.currentQuestionIndex > 0 {
            self.updateTrainingQuestionIndex((self.trainingDetail?.trainingId)!, index: self.currentQuestionIndex)
        }
        
        _ = navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func nextQuesButtonAction(_: UIButton) {
        if questionsArray.count > 0 {
            if userSelectedAnswerId! > 0 {
                saveSelectedAnswer()
                showCurrentQuestion()
                quesLabel.setNeedsDisplay()
                quesLabel.setNeedsLayout()

            } else {
                showAlertViewWithMessage(LocalizedString.shared.FAILURE_TITLE, message: LocalizedString.shared.NO_ANSWER,true)
            }
        } else {
            moveToTrainingResultController()
        }
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension TrainingQuestionsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if let question = self.currentQuestion {
            return (question.options?.count)!
        }
        return 0
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = questionsTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OptionCell
        cell.accessibilityIdentifier = "Options\(indexPath.row)"
        //        let ans = self.currentQuestion.options?[indexPath.row]
        //        cell.optionsLabel.text = ans?.answer
        if let answer: Options = self.currentQuestion.options?[indexPath.row] {
            cell.setAnswerDataInCell(answer)
        }

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = questionsTableView.cellForRow(at: indexPath) as! OptionCell
        let ans = currentQuestion.options?[indexPath.row]
        cell.optionsLabel.text = ans?.answer
        userSelectedAnswerId = (ans?.answerId)!
    }

    func tableView(_: UITableView, didDeselectRowAt _: IndexPath) {
        userSelectedAnswerId = 0
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // Adding Header in tableView
    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let headerView = self.headerView
        return headerView
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        quesLabel.sizeToFit()
        let height = currentQuestion.question?.heightWithConstrainedWidth(UIScreen.main.bounds.width - 100, font: quesLabel.font)

        return height! + itemSpacing
    }
}

// MARK: - Navigation
extension TrainingQuestionsViewController {

    func moveToTrainingResultController() {
        let storyBoard: UIStoryboard = UIStoryboard.trainingStoryboard()
        let trainingResultViewController = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.TrainingResultIdentifier) as! TrainingResultViewController
        trainingResultViewController.trainingInfo = trainingDetail
        trainingResultViewController.userSelectedAnswer = userSelectedAnswer
        trainingResultViewController.questionsArray = questionsArray
        navigationController?.pushViewController(trainingResultViewController, animated: true)
    }
}


extension TrainingQuestionsViewController {
    
    func updateTrainingQuestionIndex(_ traningId: Int, index: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            Training.syncTrainingQuizIndex(traningId as AnyObject, questionIndex: index, storeId: 1) { (success, message) in
                //api called silently
            }
        }
    }
}
