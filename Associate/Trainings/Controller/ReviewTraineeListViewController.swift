//
//  ReviewTraineeListViewController.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 09/05/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit
import Popover

let trainingListTableViewAccessibilityID = "trainingListTableView"

class ReviewTraineeListViewController: BaseViewController, FilterViewDelegate {

    // MARK: - Variables
    public var trainingArray: NSMutableArray! = NSMutableArray()
    public var selectedTrainee: User?
    
    fileprivate var currentPageNumber: Int = 1
    fileprivate var totalPages: Int = 1
    fileprivate var isInProgress: Bool = false
    fileprivate var isPullToRefresh: Bool = false
    fileprivate var indicatorFooter = UIView()
    fileprivate var selectedRowIndices: [Int] = []
    fileprivate var isSuccess: Bool = false
    
    fileprivate var selectedCategoryId:Int = -1
    fileprivate var selectedSubCategoryId:Int = -1
    //fileprivate var popover = Popover()
    fileprivate var popover = Popover(options: [.animationIn(0.001), .animationOut(0.001)] as [PopoverOption], showHandler: nil, dismissHandler: nil)
    fileprivate var categoryList: [Category]? = [Category]()

    fileprivate let cellIdentifier = "ReviewTraineeListCell"
    fileprivate let footerHeight: CGFloat = 0
    
    // MARK: - IBOutlets
    @IBOutlet weak var trainingListTableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterButton: UIButton!

    // MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.doInitialSetup()
        self.trainingListTableView.accessibilityIdentifier = trainingListTableViewAccessibilityID
        
        self.filterButton.titleLabel?.numberOfLines = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - initial setup
    func doInitialSetup() {
        super.addLeftBarButton(withImageName: Constants.BarButtonItemImage.BackArrowWhiteColor)
        navigationItem.title = selectedTrainee?.userName
        getTrainingList()
    }

     // MARK: - Actions
    override func leftButtonPressed(_: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func filterButtonAction(_: Any) {
        
        // FilterView and position
        let filterView = FilterView.filterView()
        var frm = filterView.frame
        frm.origin.y = 0
        filterView.frame = frm
        filterView.defaultButtonTitle(LocalizedString.shared.categoriesButtonString)
        filterView.delegate = self
        filterView.selectedCategoryId = self.selectedCategoryId
        filterView.selectedSubCategoryId = self.selectedSubCategoryId
        
        // Pop overview position
        let startPoint = CGPoint(x: self.filterButton.frame.width/2 + self.filterButton.frame.origin.x, y: self.filterView.frame.height + self.filterView.frame.origin.y + 60) // +44 NavBar height + 20
        let aView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 400))
        aView.addSubview(filterView)
        self.popover.popoverColor = UIColor.black
        
        // Check and category array
        if (self.categoryList?.count)! > 0 {
            self.popover.show(aView, point: startPoint)
            filterView.inlization(self.categoryList!)
        } else {
            //API for get category list
            self.getFilter { (success, categoryArray) in
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
        self.selectedCategoryId = categoryId
        self.selectedSubCategoryId = subCategoryId
        popover.dismiss()
        
        // Remove all data from table
        if (self.trainingArray?.count)! > 0 {
            self.trainingArray.removeAllObjects()
        }
        self.trainingListTableView.reloadData()
        
        if self.selectedCategoryId > -1 {
            let categoryObj:Category = self.categoryList![self.selectedCategoryId]
            let categoryName = categoryObj.catName
            
            var subCategoryId = 0
            var subCategoryName = ""
            if self.selectedSubCategoryId > -1 {
                let subCategories = categoryObj.subCatList
                subCategoryName = (subCategories?[self.selectedSubCategoryId].subCatName)!
                subCategoryId = (subCategories?[self.selectedSubCategoryId].subCatId)!
            }
            self.setCategoryButton(title: categoryName!, andSubTitle: subCategoryName)
            self.getTrainingByFilter(categoryObj.catId!, subCategoryId: subCategoryId)
        }
    }
    
    func defaultButtonTapped() {
        
        // Reset default
        self.defaultFilterButton()
        
        // Remove all data from table
        if (self.trainingArray?.count)! > 0 {
            self.trainingArray.removeAllObjects()
        }
        
        // Remove popover view
        self.popover.dismiss()
        
        // Default Api
        //self.getTrainingByFilter(0, subCategoryId: 0)
        self.getTrainingList()
    }
    
    func defaultFilterButton() {
        // Reset default value
        self.selectedCategoryId = -1
        self.selectedSubCategoryId = -1
        
        // Set default button title
        self.setCategoryButton(title: LocalizedString.shared.categoriesButtonString, andSubTitle: "")
    }
    
    // Set Category Button Title and SubTitle
    func setCategoryButton(title:String, andSubTitle subTitle:String) {
        if subTitle.characters.count > 0 {
            self.filterButton.setTitleAndSubtitle(title: title, subTitle: subTitle)
        } else {
            self.filterButton.setAttributedTitle(nil, for: .normal)
            self.filterButton.setTitle(title, for: .normal)
        }
    }

}

 // MARK: - UITableViewDataSource, UITableViewDelegate, ReviewTraineeListCellDelegate
extension ReviewTraineeListViewController: UITableViewDataSource, UITableViewDelegate, ReviewTraineeListCellDelegate {

    // MARK: UITableView
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return trainingArray.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = trainingListTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ReviewTraineeListCell
        cell.accessibilityIdentifier = "ReviewTraineeListCell\(indexPath.row)"
        cell.delegate = self
        if let training: Training = self.trainingArray[indexPath.row] as? Training {
            cell.setAssociateTrainingDataInCell(training, withIndexPath: indexPath)
        }
        return cell
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 166.0
        
        for selectedIndex in selectedRowIndices{
        if indexPath.row == selectedIndex {
            if isSuccess {
                height = 116.0
            } else {
                height = 166.0
            }
            }
        } 
        
        return height
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

    // MARK: - ReviewTraineeListCell's ReviewTraineeListCellDelegate
    func cellButtonAction(_ isApprove: Bool, _ indexPath: IndexPath) {
        
        self.showAlertViewWithMessageAndDicisionHandler(LocalizedString.shared.INFORMATION_TITLE, message: LocalizedString.shared.TRAINING_APPROVE, trueButtonText: LocalizedString.shared.YES, falseButtonText: LocalizedString.shared.NO, trueActionHandler: {
            
            // call training index and call api
            let trainingObj: Training = self.trainingArray[indexPath.row] as! Training
            self.acceptOrRejectTraining(action: isApprove, trainingId: trainingObj.trainingId!,selectedIndex: indexPath)
            self.selectedRowIndices.append(indexPath.row)
        }) {
            // No Section here
        }
    }
    
    func updateCell(_ selectedIndex: IndexPath) {
        let cell = self.trainingListTableView.cellForRow(at: selectedIndex) as! ReviewTraineeListCell
        
        self.trainingListTableView.beginUpdates()
        cell.approveButton.isHidden = true
        cell.rejectButton.isHidden = true
        self.trainingListTableView.endUpdates()
    }
}

//MARK: - ReviewTraineeListViewController
extension ReviewTraineeListViewController {

    func moveToFilterView() {
        let storyboard = UIStoryboard.associateTrainingStoryboard()
        let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.filterIdentifier) as! FilterViewController
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
}

//MARK: - API Calls
extension ReviewTraineeListViewController {
    
    func getTrainingByFilter(_ categoryId:Int, subCategoryId:Int) {
        trainingListTableView.tableFooterView = totalPages == currentPageNumber ? indicatorFooter : UIView()
        
        var catId = categoryId
        if catId == -1 {
            catId = 0
        }
        var subCatId = subCategoryId
        if subCatId == -1 {
            subCatId = 0
        }
        Helper.showLoader()
        CategoryService.getTrainingByFilter((self.selectedTrainee?.userId)!, catId, subCategoryId: subCatId,  pageNumber: currentPageNumber, completionHandler: { (success, message, resultArray, pageCount) -> Void in
            self.isInProgress = false
            Helper.hideLoader()
            
            if let _ = self.trainingListTableView.infiniteScrollingView {
                self.trainingListTableView.infiniteScrollingView.stopAnimating()
            }
            
            if let _ = self.trainingListTableView.pullToRefreshView {
                self.trainingListTableView.pullToRefreshView.stopAnimating()
            }
            
            if success {
                print("Trainings fetched from server")
                self.totalPages = pageCount
                
                // Do not reload here. Wait untill we trainings are cached in coredata
                
                // Load More - add object if user use loadmore in tableview
                if (resultArray?.count)! > 0 {
                    self.trainingArray.addObjects(from: resultArray!)
                    self.trainingListTableView.reloadData()
                } else {
                    // Show no request and get back
                    if self.currentPageNumber == 1 {
                        self.showAlertViewWithMessageAndActionHandler(LocalizedString.shared.INFORMATION_TITLE, message: LocalizedString.shared.NO_TRAINEE_REQUEST, actionHandler: {
                            self.leftButtonPressed(UIButton())
                        })
                    }
                }
            }
            
            if self.isPullToRefresh == true {
                self.isPullToRefresh = false
                
                // Remove all training objects and reload fresh data with page count 1
                self.trainingArray.removeAllObjects()
                self.trainingListTableView.reloadData()
            }
            
        })
    }
    
    
    func getTrainingList() {
        trainingListTableView.tableFooterView = totalPages == currentPageNumber ? indicatorFooter : UIView()

        CategoryService.getAssociatesTraineeTraining((selectedTrainee?.userId)!, pageNumber: currentPageNumber, completionHandler: { (success, _, resultArray, pageCount) -> Void in
            self.isInProgress = false
            Helper.hideLoader()

            if let _ = self.trainingListTableView.infiniteScrollingView {
                self.trainingListTableView.infiniteScrollingView.stopAnimating()
            }

            if let _ = self.trainingListTableView.pullToRefreshView {
                self.trainingListTableView.pullToRefreshView.stopAnimating()
            }

            if success {
                print("Trainings fetched from server")
                self.totalPages = pageCount
                
                // Do not reload here. Wait untill we trainings are cached in coredata
                
                // Load More - add object if user use loadmore in tableview
                if (resultArray?.count)! > 0 {
                    self.trainingArray.addObjects(from: resultArray!)
                    self.trainingListTableView.reloadData()
                } else {
                    // Show no request and get back
                    if self.currentPageNumber == 1 {
                        self.showAlertViewWithMessageAndActionHandler(LocalizedString.shared.INFORMATION_TITLE, message: LocalizedString.shared.NO_TRAINEE_REQUEST, actionHandler: {
                            self.leftButtonPressed(UIButton())
                        })
                    }
                }
            }

            if self.isPullToRefresh == true {
                self.isPullToRefresh = false

                // Remove all training objects and reload fresh data with page count 1
                self.trainingArray.removeAllObjects()
                self.trainingListTableView.reloadData()
            }

        })
    }

    func pullToRefresh() {
        
        // Set filter button default
        self.defaultFilterButton()
        
        isSuccess = false
        trainingListTableView.addPullToRefresh {
            self.currentPageNumber = 1
            self.isPullToRefresh = true
            
            self.selectedCategoryId = -1
            self.selectedSubCategoryId = -1
            self.getTrainingByFilter(0, subCategoryId: 0)
        }
    }

    // Pagination in listing
    func loadMorePages() {
        trainingListTableView.addInfiniteScrolling {
            if !self.isInProgress && self.currentPageNumber <= self.totalPages {
                self.currentPageNumber = self.currentPageNumber + 1
                self.isInProgress = true
                
                if self.selectedCategoryId == -1 {
                    self.selectedCategoryId = 0
                }
                if self.selectedSubCategoryId == -1 {
                    self.selectedSubCategoryId = 0
                }
                self.getTrainingByFilter(self.selectedCategoryId, subCategoryId: self.selectedSubCategoryId)
                
            } else {
                if let _ = self.trainingListTableView.infiniteScrollingView {
                    self.trainingListTableView.infiniteScrollingView.stopAnimating()
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

    func acceptOrRejectTraining(action: Bool, trainingId: Int, selectedIndex: IndexPath) {
        Helper.showLoader()
        CategoryService.traineeTrainingApproveReject((selectedTrainee?.userId)!, trainingId, action) { success, message in
            Helper.hideLoader()
            if success {
                self.isSuccess = success
                // update the height for all the cells
                self.updateCell(selectedIndex)
            } else {
                self.showAlertViewWithMessage(LocalizedString.shared.ERROR_TITLE, message: message!)
            }
        }
    }
    
    // MARK: Filter by training
    func getFilter(_ completionHandler: @escaping (_ success: Bool, _ resultArray: [Category]?)->Void) {
        
        Helper.showLoader()
        CategoryService.getCategoryForTraining((self.selectedTrainee?.userId!)!, pageNumber: 1) { success, _, categoryArray, _ in
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
        showAlertViewWithMessage(LocalizedString.shared.INFORMATION_TITLE, message: LocalizedString.shared.NO_FILTER)
    }

}
