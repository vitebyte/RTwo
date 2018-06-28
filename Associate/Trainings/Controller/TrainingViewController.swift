//
//  TrainingViewController.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 15/03/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit
import SVPullToRefresh
import CoreData
import CoreStore
import Popover

//MARK: Global variable
let trainingtableViewAccessibilityID = "trainingtableView"

class TrainingViewController: BaseViewController, FilterViewDelegate {

    //MARK: Variables
    public let footerHeight: CGFloat = 0
    public let cellIdentifier = "CellTraining"
    public var trainingArray: NSMutableArray! = NSMutableArray()
    
    fileprivate var currentPageNumber: Int = 1
    fileprivate var totalPages: Int = 1
    fileprivate var isInProgress: Bool = false
    fileprivate var isPullToRefresh: Bool = false
    fileprivate var indicatorFooter = UIView()

    fileprivate var selectedCategoryId: Int = -1
    fileprivate var selectedSubCategoryId: Int = -1
    fileprivate var currentPageNumberFilter: Int = 1
    fileprivate var totalPagesFilter: Int = 1
    fileprivate var isInProgressFilter: Bool = false
    fileprivate var isPullToRefreshFilter: Bool = false
    fileprivate var indicatorFooterFilter = UIView()
    fileprivate var popover = Popover(options: [.animationIn(0.001), .animationOut(0.001)] as [PopoverOption], showHandler: nil, dismissHandler: nil)
    fileprivate var isApplyFilter: Bool = false
    fileprivate var categoryList: [Category]? = [Category]()

    // MARK: - IBOutlets
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var middleImageView: UIImageView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var trainingtableView: UITableView!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var reviewTraineeButton: UIButton!
    @IBOutlet weak var reviewResultsLabel: UILabel!
    @IBOutlet weak var filtersView: UIView!

    //MARK: View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        super.addRightBarButton(withImageName: Constants.BarButtonItemImage.MoreWhiteColor)

        trainingtableView.accessibilityIdentifier = trainingtableViewAccessibilityID

        // setup view
        setCircularImageView()

        // register scroll events
        loadMorePages()
        pullToRefresh()

        trainingArray = NSMutableArray()
        TrainingsManager.shared.delegate = self

        categoriesButton.setTitle(LocalizedString.shared.categoriesButtonString, for: .normal)
        categoriesButton.titleLabel?.numberOfLines = 0

        // get trainings from server
        Helper.showLoader()
        getTrainingList(0, subCatId: 0)

        // Get associate trainees
        getAssociateTrainee()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)

        super.navigationBarAppearanceBlack(navController: navigationController!)

        handleLocalizeStrings()

        // refresh training list with updated dataset from coredata
        TrainingsManager.shared.refreshTrainings()
    }

    override func viewWillDisappear(_: Bool) {
        // NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Helper Methods
    func handleLocalizeStrings() {
        navigationItem.title = LocalizedString.shared.yourTrainingTitleString
        reviewResultsLabel.text = LocalizedString.shared.reviewResultsString
        categoriesButton.setTitle(LocalizedString.shared.categoriesButtonString, for: .normal)
    }

    func setCircularImageView() {
        view.layoutIfNeeded()
        setBorderColor(imageView: topImageView, borderWidth: 2.0, borderColor: UIColor.white)
        setBorderColor(imageView: middleImageView, borderWidth: 2.0, borderColor: UIColor.white)
        setBorderColor(imageView: bottomImageView, borderWidth: 0.1, borderColor: UIColor.init(hexColorCode: Constants.ColorHexCodes.dustyGrayColor))
    }

    func setBorderColor(imageView: UIImageView, borderWidth: CGFloat, borderColor: UIColor) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.borderWidth = borderWidth
        imageView.layer.borderColor = borderColor.cgColor
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
    }

    func moveToFilterViewController(_ filterArray: [Category]) {
        let storyboard = UIStoryboard.associateTrainingStoryboard()
        let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.filterIdentifier) as! FilterViewController
        controller.filterArray = filterArray
        controller.modalPresentationStyle = UIModalPresentationStyle.popover
        let popoverPresentationController = controller.popoverPresentationController
        popoverPresentationController?.delegate = self
        // result is an optional (but should not be nil if modalPresentationStyle is popover)
        if let _popoverPresentationController = popoverPresentationController {
            // set the view from which to pop up
            _popoverPresentationController.sourceView = view
            controller.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            let navBar = UINavigationController(rootViewController: controller)
            navigationController?.present(navBar, animated: true, completion: nil)
        }
    }

    // MARK: - IBAction Methods
    @IBAction func reviewTraineeButtonSelected(_: Any) {
        moveToReviewTraineeViewController()
    }

    @IBAction func filterButtonClicked(_: UIButton) {

        // FilterView and position
        let filterView = FilterView.filterView()
        var frm = filterView.frame
        frm.origin.y = 0
        filterView.frame = frm
        filterView.defaultButtonTitle(LocalizedString.shared.categoriesButtonString)
        filterView.delegate = self
        filterView.selectedCategoryId = selectedCategoryId
        filterView.selectedSubCategoryId = selectedSubCategoryId

        // Pop overview position
        let startPoint = CGPoint(x: categoriesButton.frame.width / 2 + categoriesButton.frame.origin.x, y: filtersView.frame.height + filtersView.frame.origin.y + 60) // +44 NavBar height + 20
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 400))
        aView.addSubview(filterView)
        popover.popoverColor = UIColor.black

        // Check and category array
        if (categoryList?.count)! > 0 {
            popover.show(aView, point: startPoint)
            filterView.inlization(categoryList!)
        } else {
            // API for get category list
            getFilter { success, categoryArray in
                if success {
                    self.categoryList = categoryArray
                    self.popover.show(aView, point: startPoint)
                    filterView.inlization(self.categoryList!)
                }
            }
        }
    }

    // MARK: - FilterViewDelegate
    // FilterViewDelegate - Popoverview delegate
    func applyButtonTapped(_ categoryId: Int, _ subCategoryId: Int) {
        print("Selected cat and subcat : \(categoryId), \(subCategoryId)")
        selectedCategoryId = categoryId
        selectedSubCategoryId = subCategoryId
        popover.dismiss()

        if selectedCategoryId > -1 {
            let categoryObj: Category = categoryList![self.selectedCategoryId]
            let categoryName = categoryObj.catName

            var subCategoryId = 0
            var subCategoryName = ""
            if selectedSubCategoryId > -1 {
                let subCategories = categoryObj.subCatList
                subCategoryName = (subCategories?[self.selectedSubCategoryId].subCatName)!
                subCategoryId = (subCategories?[self.selectedSubCategoryId].subCatId)!
            }

            // Remove all data from table
            if (trainingArray?.count)! > 0 {
                trainingArray.removeAllObjects()
            }
            trainingtableView.reloadData()

            setCategoryButton(title: categoryName!, andSubTitle: subCategoryName)
            getTrainingList(categoryObj.catId!, subCatId: subCategoryId)
        }
    }

    func defaultButtonTapped() {

        // Reset default
        defaultFilterButton()

        // Remove all data from table
        if (trainingArray?.count)! > 0 {
            trainingArray.removeAllObjects()
        }
        trainingtableView.reloadData()

        // Remove popover view
        popover.dismiss()

        // Default Api
        defaultFilterButton()
        getTrainingList(0, subCatId: 0)
    }

    func defaultFilterButton() {
        // Reset default value
        selectedCategoryId = -1
        selectedSubCategoryId = -1

        // Set default button title
        setCategoryButton(title: LocalizedString.shared.categoriesButtonString, andSubTitle: "")
    }

    // Set Category Button Title and SubTitle
    func setCategoryButton(title: String, andSubTitle subTitle: String) {
        if subTitle.characters.count > 0 {
            categoriesButton.setTitleAndSubtitle(title: title, subTitle: subTitle)
        } else {
            categoriesButton.setAttributedTitle(nil, for: .normal)
            categoriesButton.setTitle(title, for: .normal)
        }
    }
}


//MARK: - UITableViewDataSource, UITableViewDelegate
extension TrainingViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: UITableView
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return trainingArray.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = trainingtableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TrainingCell
        cell.accessibilityIdentifier = "TrainingCell\(indexPath.row)"
        if let training: Training = self.trainingArray[indexPath.row] as? Training {
            cell.setTrainingDataInCell(training)
        }
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let training: Training = self.trainingArray[indexPath.row] as? Training {
            if training.status == TrainingStatus.Expired.hashValue {
                showAlertViewWithMessage(LocalizedString.shared.INFORMATION_TITLE, message: LocalizedString.shared.TRAINING_EXPIRED,true)
            } else {
                // check attempts
                moveToTrainingDetailWithData(training)
            }
        }
    }

    // Adding footer in tableView
    func tableView(_ tableView: UITableView, viewForFooterInSection _: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: footerHeight))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return footerHeight
    }
}

//MARK: - API Calls
extension TrainingViewController {
    func getTrainingList(_ catId: Int, subCatId: Int) {
        trainingtableView.tableFooterView = totalPages == currentPageNumber ? indicatorFooter : UIView()

        TrainingsManager.shared.getTrainings(catId, subCatId: subCatId, pageNumber: currentPageNumber) { (success, _, resultArray, _, pageCount) -> Void in
            self.isInProgress = false
            Helper.hideLoader()

            if let _ = self.trainingtableView.infiniteScrollingView {
                self.trainingtableView.infiniteScrollingView.stopAnimating()
            }

            if let _ = self.trainingtableView.pullToRefreshView {
                self.trainingtableView.pullToRefreshView.stopAnimating()
            }

            if success {
                print("Trainings fetched from server")
                self.totalPages = pageCount

                if self.isPullToRefresh {
                    self.isPullToRefresh = false

                    if self.trainingArray.count > 0 {
                        self.trainingArray.removeAllObjects()
                    }
                }

                if (resultArray?.count)! > 0 {
                    for arrayObj in resultArray! {
                        self.trainingArray.add(arrayObj)
                    }
                    self.trainingtableView.reloadData()
                }
            }

            // TrainingsManager.shared.refreshTrainings()
        }
    }

    func pullToRefresh() {
        
        // Set filter button default
        self.defaultFilterButton()

        trainingtableView.addPullToRefresh {
            self.currentPageNumber = 1
            self.isPullToRefresh = true

            self.selectedCategoryId = -1
            self.selectedSubCategoryId = -1
            self.getTrainingList(0, subCatId: 0)
        }
    }

    // Pagination in listing
    func loadMorePages() {
        trainingtableView.addInfiniteScrolling {
            if !self.isInProgress && self.currentPageNumber <= self.totalPages {
                self.currentPageNumber = self.currentPageNumber + 1
                self.isInProgress = true
                if self.selectedCategoryId == -1 {
                    self.selectedCategoryId = 0
                }
                if self.selectedSubCategoryId == -1 {
                    self.selectedSubCategoryId = 0
                }
                self.getTrainingList(self.selectedCategoryId, subCatId: self.selectedSubCategoryId)
            } else {
                if let _ = self.trainingtableView.infiniteScrollingView {
                    self.trainingtableView.infiniteScrollingView.stopAnimating()
                }
            }
        }
    }

    // Get Associate Trainee List
    func getAssociateTrainee() {

        let user: User = UserManager.shared.activeUser
        Helper.showLoader()
        user.getTraineesList(1) { success, _, _, _, _ in
            Helper.hideLoader()

            if success {
                // Update UI

            }
        }
    }

    // MARK: - Filter by training
    func getFilter(_ completionHandler: @escaping (_ success: Bool, _ resultArray: [Category]?) -> Void) {

        Helper.showLoader()
        CategoryService.getCategoryForTraining(UserManager.shared.activeUser.userId!, pageNumber: 1) { success, _, categoryArray, _ in
            Helper.hideLoader()

            if success {
                if (categoryArray?.count)! > 0 {
                    completionHandler(true, categoryArray)
                } else {
                    self.showMessageForNoCategoryResult()
                    completionHandler(false, nil)
                }
            } else {
                self.showMessageForNoCategoryResult()
                completionHandler(false, nil)
            }
        }
    }

    // MARK: Show error message when no category/filter data
    func showMessageForNoCategoryResult() {
        showAlertViewWithMessage(LocalizedString.shared.INFORMATION_TITLE, message: LocalizedString.shared.NO_FILTER,true)
    }

    // Filtered training list
    func getFilteredList(_: Int, subCategory _: Int) {
        // will be implemented 
    }
}

//MARK: - TrainingsManagerDelegate
extension TrainingViewController: TrainingsManagerDelegate {
    func trainingsLoaded(_ arrayTrainings: [Training]) {
        trainingArray = NSMutableArray(array: arrayTrainings)
        trainingtableView.reloadData()
    }
}

// MARK: - Navigation
extension TrainingViewController {

    func moveToTrainingDetailWithData(_ trainingData: Training) {
        let storyBoard: UIStoryboard = UIStoryboard.trainingStoryboard()
        let trainingDetailViewController = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.TrainingDetailViewController) as! TrainingDetailViewController
        trainingDetailViewController.trainingInfo = trainingData
        trainingDetailViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(trainingDetailViewController, animated: true)
    }

    func moveToResultView(_ trainingData: Training) {
        let storyBoard: UIStoryboard = UIStoryboard.trainingStoryboard()
        let trainingResultViewController = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.TrainingResultIdentifier) as! TrainingResultViewController
        trainingResultViewController.trainingInfo = trainingData
        trainingResultViewController.isComeFromTrainimg = true
        trainingResultViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(trainingResultViewController, animated: true)
    }

    func moveToReviewTraineeViewController() {
        let storyBoard: UIStoryboard = UIStoryboard.trainingStoryboard()
        let reviewTraineeViewController = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.ReviewTraineeIdentifier) as! ReviewTraineeViewController

        reviewTraineeViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(reviewTraineeViewController, animated: true)
    }
}
