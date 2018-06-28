//
//  ReviewTraineeViewController.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 09/05/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

let traineetableViewAccessibilityID = "traineetableView"

class ReviewTraineeViewController: BaseViewController {

    //MARK: - Variables
    public var traineeArray: NSMutableArray! = NSMutableArray()
    fileprivate var currentPageNumber: Int = 1
    fileprivate var totalPages: Int = 1
    fileprivate var isInProgress: Bool = false
    fileprivate var isPullToRefresh: Bool = false
    fileprivate var indicatorFooter = UIView()
    fileprivate let cellIdentifier = "ReviewTraineeCell"
    fileprivate var selectedTrainee: User?

    // MARK: - IBOutlets
    @IBOutlet weak var traineetableView: UITableView!

    // MARK: - View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        traineetableView.accessibilityIdentifier = traineetableViewAccessibilityID
        getTraineeList()
        doInitialSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions
    override func leftButtonPressed(_: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }

    //MARK: - Initial setup
    func doInitialSetup() {
        super.addLeftBarButton(withImageName: Constants.BarButtonItemImage.BackArrowWhiteColor)
        navigationItem.title = LocalizedString.shared.trainingTitle
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension ReviewTraineeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return traineeArray.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = traineetableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ReviewTraineeCell
        cell.accessibilityIdentifier = "ReviewTraineeCell\(indexPath.row)"
        let disclosureImage = UIImage(named: "cellIndicator.png")
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = UIImageView(image: disclosureImage!)
        cell.setDataOfTrainees(user: traineeArray[indexPath.row] as! User)
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTrainee = traineeArray[indexPath.row] as? User
        moveToTraineeTrainingListViewController()
    }
}

// MARK: - Navigation
extension ReviewTraineeViewController {
    func moveToTraineeTrainingListViewController() {
        let storyBoard: UIStoryboard = UIStoryboard.trainingStoryboard()
        let reviewTraineeListViewController = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.ReviewTraineeListIdentifier) as! ReviewTraineeListViewController
        reviewTraineeListViewController.selectedTrainee = selectedTrainee
        navigationController?.pushViewController(reviewTraineeListViewController, animated: true)
    }
}

// MARK: - API calls
extension ReviewTraineeViewController {

    // Get Associate Trainee List
    func getTraineeList() {
        traineetableView.tableFooterView = totalPages == currentPageNumber ? indicatorFooter : UIView()

        let user: User = UserManager.shared.activeUser
        Helper.showLoader()
        user.getTraineesList(currentPageNumber) { (success, _, resultArray, _, pageCount) -> Void in
            self.isInProgress = false
            Helper.hideLoader()

            if let _ = self.traineetableView.infiniteScrollingView {
                self.traineetableView.infiniteScrollingView.stopAnimating()
            }

            if let _ = self.traineetableView.pullToRefreshView {
                self.traineetableView.pullToRefreshView.stopAnimating()
            }

            if success {
                self.totalPages = pageCount

                // Load More - add object if user use loadmore in tableview
                if (resultArray?.count)! > 0 {
                    self.traineeArray.addObjects(from: resultArray!)
                    self.traineetableView.reloadData()
                } else {
                    // Show no trainee message and get back
                    if self.currentPageNumber == 1 {
                        self.showAlertViewWithMessageAndActionHandler(LocalizedString.shared.INFORMATION_TITLE, message: LocalizedString.shared.NO_TRAINEE, actionHandler: {
                            self.leftButtonPressed(UIButton())
                        })
                    }
                }
            }

            if self.isPullToRefresh == true {
                self.isPullToRefresh = false

                // Remove all training objects and reload fresh data with page count 1
                self.traineeArray.removeAllObjects()
                self.traineetableView.reloadData()
            }

            TrainingsManager.shared.refreshTrainings()
        }
    }

    func pullToRefresh() {

        traineetableView.addPullToRefresh {
            self.currentPageNumber = 1
            self.isPullToRefresh = true
            self.getTraineeList()
        }
    }

    // Pagination in listing
    func loadMorePages() {
        traineetableView.addInfiniteScrolling {
            if !self.isInProgress && self.currentPageNumber <= self.totalPages {
                self.currentPageNumber = self.currentPageNumber + 1
                self.isInProgress = true
                self.getTraineeList()
            } else {
                if let _ = self.traineetableView.infiniteScrollingView {
                    self.traineetableView.infiniteScrollingView.stopAnimating()
                }
            }
        }
    }
}
