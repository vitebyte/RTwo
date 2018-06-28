//
//  FeedUpdateCell.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 19/05/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

protocol FeedUpdateCellDelegate {
    func markAsReadTapped(indexPath: IndexPath, isFromConfirm: Bool)
    func imageButtonTapped(indexPath: IndexPath, feed: Feed)
}

class FeedUpdateCell: UITableViewCell {
    
    // MARK: - Variables
    var delegate: FeedUpdateCellDelegate?
    var selectedIndexPath: IndexPath?
    var cellIdentifier: String = "FeedOptionsCell"
    var collectionIdentifier: String = "FeedImageCell"
    var alphabeticalBullets = ["A.", "B.", "C.","D.","E.","F."]
    var optionsCellTapped: Bool = false
    var currentOptionsIndexPath: IndexPath?
    var selectedOptionsIndexPath: IndexPath?
    var unselectedOptionsArray: [IndexPath] = [IndexPath]()
    var feedData: Feed = Feed()
    var optionsData: [Options] = [Options]()
    var count: Int = 0
    var questionsArray = [Question]()
    var currentQuestion = Question()
    fileprivate var currentQuestionIndex: Int = 0

    // MARK: -Outlets
    @IBOutlet weak var readViewConstant: NSLayoutConstraint!
    @IBOutlet weak var markReadView: UIView!
    @IBOutlet weak var markReadButton: UIButton!
    @IBOutlet weak var feedDataView: UIView!
    @IBOutlet weak var feedImageButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusUpdateLabel: UILabel!
    @IBOutlet weak var feedQuestionsView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var optionsTableView: UITableView!
    
    @IBOutlet weak var feedCollectionView: UICollectionView!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    var answeredIndex: IndexPath = IndexPath.init(item: 0, section: 2)
    
    // MARK: - View life cycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.feedCollectionView.dataSource = self
        self.feedCollectionView.delegate = self

        self.currentQuestionIndex = 0
        self.optionsTableView.estimatedRowHeight = 135
        self.optionsTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - setup data
    func setDataInFeedUpdateCell(feed: Feed, indexPath: IndexPath, isRead: Bool){
        self.selectedIndexPath = indexPath
        feedData = feed
        self.currentQuestionIndex = 0
        if feed.questionFlag! {
            self.questionsArray = feed.questions!
        }
        self.feedDataView.isHidden = false
        self.feedQuestionsView.isHidden = true
        self.markReadButton.setTitle("Mark as Read", for: .normal)
        self.markReadButton.setTitleColor(UIColor.init(hexColorCode: "#ffffff", alpha: 1.0), for: .normal)
        
        if feed.ackFlag! {
        self.markReadButton.isHidden = true
        self.readViewConstant.constant = 0
            
        } else {
            self.markReadButton.isHidden = false
            self.readViewConstant.constant = 52
        }
        self.titleLabel.text = feed.content?.html2String
        self.statusUpdateLabel.text = feed.feedInterval
        
        // Set image and video data
        self.count = 0
        if let imgData = feed.feedsImage {
            if imgData.characters.count > 2 {
            count = count + 1
            }
        }
        if let videoData = feed.feedsVideo {
            if videoData.characters.count > 2 {
            count = count + 1
            }
        }
        self.feedCollectionView.reloadData()
    }
    
    func setCorrectOrIncorrect(options: [Options], indexPath: IndexPath ) {
        
        if options[(selectedOptionsIndexPath?.row)!].answerFlag! == true {
            self.answerLabel.text = "CORRECT"
            self.correctLabel.isHidden = true
        } else {
            self.answerLabel.text = "INCORRECT"
            self.correctLabel.isHidden = false
        }
    }
    
    func setQuestionsInFeedCell(feed: Feed, indexPath: IndexPath){
        self.selectedIndexPath = indexPath
        self.answerView.isHidden = true
        self.feedDataView.isHidden = true
        self.questionsArray = feed.questions!
        self.optionsData = self.questionsArray[currentQuestionIndex].options!
        self.showCurrentQuestion()
        
        // Question Table Datasource and Delegate
        self.optionsTableView.dataSource = self
        self.optionsTableView.delegate = self
        
        self.feedQuestionsView.isHidden = false
        self.markReadButton.setTitle("Confirm Answer", for: .normal)
        self.markReadButton.setTitleColor(UIColor.init(hexColorCode: "#ffffff", alpha: 0.2), for: .normal)
        self.optionsTableView.reloadData()
        
    }
    
    func showCurrentQuestion() {
        if currentQuestionIndex < questionsArray.count + 1{
            currentQuestion = (questionsArray[self.currentQuestionIndex])
            currentQuestionIndex += 1
            }
    }
    
    func findCorrectOption() -> IndexPath {
        self.markReadButton.setTitleColor(UIColor.init(hexColorCode: "#ffffff", alpha: 1.0), for: .normal)
        for i in 0..<optionsData.count {
            if optionsData[i].answerFlag! {
                self.currentOptionsIndexPath = IndexPath.init(row: i, section: 0)
            }
        }
                return currentOptionsIndexPath!
    }
    
    // MARK: - Actions
       @IBAction func markReadButtonAction(_ sender: Any) {
        if feedData.questionFlag! {
        
        if optionsCellTapped {
            optionsCellTapped = false
            let top: IndexPath = IndexPath.init(row: 0, section: 0)
            optionsTableView.selectRow(at: self.currentOptionsIndexPath, animated: true, scrollPosition: .top)
            self.answeredIndex = self.selectedIndexPath!
            self.answerView.alpha = 0.0
            self.answerView.backgroundColor = UIColor.white
     
            self.setCorrectOrIncorrect(options: optionsData, indexPath: self.currentOptionsIndexPath!)
            self.markReadButton.isHidden = true
            self.readViewConstant.constant = 0
            
            if currentQuestionIndex < questionsArray.count {
                self.markReadButton.isHidden = false
                self.markReadButton.setTitle("Next", for: .normal)
                self.readViewConstant.constant = 52
            }
     
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
                self.answerView.isHidden = false
                self.answerView.alpha = 1.0
                
            }, completion: { (success) in
                if self.currentQuestionIndex < self.questionsArray.count {
                    self.setQuestionsInFeedCell(feed: self.feedData, indexPath: self.selectedIndexPath!)
                } else {
                if success {
                     self.currentQuestionIndex =  0
                    self.delegate?.markAsReadTapped(indexPath: self.selectedIndexPath!, isFromConfirm: true)
                   
                }
                }
            })
        }  else {
            self.answeredIndex = self.selectedIndexPath!
            self.delegate?.markAsReadTapped(indexPath: selectedIndexPath!, isFromConfirm: false)
        }
        } else {
            self.delegate?.markAsReadTapped(indexPath: self.selectedIndexPath!, isFromConfirm: true)
        }
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension FeedUpdateCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQuestion.options!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = optionsTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FeedOptionsCell
        if indexPath.row  != 0 {
            unselectedOptionsArray.append(indexPath)
        }
        cell.alphabeticalListLabel.text = alphabeticalBullets[indexPath.row]
        cell.optionsLabel.text = currentQuestion.options?[indexPath.row].answer
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedOptionsIndexPath = indexPath
        var _ = self.findCorrectOption()
        self.optionsCellTapped = true

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 78))
        let label = UILabel(frame: CGRect(x: 11, y: 13, width: (UIScreen.main.bounds.width - 32), height: 42))
        label.numberOfLines = 0
        label.font = UIFont.gothamLight(15)
        label.text = currentQuestion.question
        label.sizeToFit()
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let labelHeight = (feedData.questions?.first?.question?.heightWithConstrainedWidth(UIScreen.main.bounds.width - 32, font: UIFont.gothamLight(15)))
        return labelHeight! + CGFloat(29.0)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FeedUpdateCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.feedCollectionView.dequeueReusableCell(withReuseIdentifier: collectionIdentifier, for: indexPath) as! FeedImageCell
        cell.setDataOnFeedCollectionCell(feed: feedData, indexpath: indexPath)
        // Configure the cell
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.imageButtonTapped(indexPath: indexPath, feed: feedData)
    }
    
       
   }
