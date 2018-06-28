//
//  FeedsViewController.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 22/03/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit
import AVKit

class FeedsViewController: BaseViewController, UIScrollViewDelegate {

    //MARK: -  Variables
    fileprivate let cellIdentifier = "FeedUpdateCell"
    fileprivate var heightOfCell = 271
    fileprivate var cellSelected: Bool = false
    fileprivate var confirmAnswerSelected : Bool = false
    fileprivate var selectedRowIndices: [IndexPath] = []
    fileprivate var currentPageNumber: Int = 1
    fileprivate var totalPages: Int = 1
    fileprivate var isInProgress: Bool = false
    fileprivate var isPullToRefresh: Bool = false
    fileprivate var indicatorFooter = UIView()
    public var feedsArray: NSMutableArray! = NSMutableArray()

    var feedImageUrl:  String?
    var selectedIndexPath: IndexPath?
    var feedInfo: [Feed] = [Feed]()
    var feed: Feed = Feed()
    var readFeeds: [Feed] = [Feed]()
    var unReadFeeds: [Feed] = [Feed]()
    var feedRead: Feed = Feed()
    var height: CGFloat = 50

    //MARK: -  Outlets
    @IBOutlet weak var closeImageButton: UIButton!
    @IBOutlet weak var feedsTableView: UITableView!
    @IBOutlet weak var feedShowImageView: UIView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        super.navigationBarAppearanceBlack(navController: navigationController!)
        
        feedsTableView.contentInset = UIEdgeInsetsMake(-15, 0, 0, 0)
        feedsTableView.estimatedRowHeight = 306
        feedsTableView.rowHeight = UITableViewAutomaticDimension
        feedShowImageView.alpha = 0.0
        self.feedShowImageView.isHidden = true
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        self.scrollView.delegate = self
        self.feedImageView.contentMode = .scaleAspectFit
        self.feedsTableView.backgroundColor = UIColor.white
        self.getFeedsList()
        self.loadMorePages()
        self.pullToRefresh()
        
        self.closeImageButton.layer.shadowColor = UIColor.black.cgColor
        self.closeImageButton.layer.shadowOpacity = 1.0
        self.closeImageButton.layer.shadowRadius = 1.0
        self.closeImageButton.layer.shadowOffset = CGSize.init(width: 0.0, height: 3.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        
               self.doInitialSetup()
        self.handleLocalizeStrings()
//        self.feedImageView.isHidden = true
    }

    // MARK: - Helper Methods
    func prepareAcknowledgementArray() {
        for temp in feedsArray {
            if let tempFeed:Feed = (temp as! Feed) {
                if tempFeed.ackFlag! {
                    readFeeds.append(tempFeed)
                } else {
                    unReadFeeds.append(tempFeed)
                }
            }
        }
        
    }
    
    func doInitialSetup() {
        super.addRightBarButton(withImageName: Constants.BarButtonItemImage.MoreWhiteColor)
    }

    func handleLocalizeStrings() {
        self.navigationItem.title = LocalizedString.shared.feedTitleString
    }
    
    func manageReadAndUnreadData(index: IndexPath){
        feedRead = unReadFeeds[index.row]
        unReadFeeds.remove(at: index.row)
        readFeeds.append(feedRead)
        feedsTableView.reloadData()
    }
    
   // MARK: - Actions
    @IBAction func closeButtonAction(_ sender: Any) {
        self.removeAnimate()
    }

    
    // MARK: - Scrollview delgate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.feedImageView
    }
   
}

// MARK: -  UITableViewDataSource, UITableViewDelegate
extension FeedsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return unReadFeeds.count
        } else if section == 1 {
            return readFeeds.count
        } else {
            return 0
        }
    }
    
    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedsTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FeedUpdateCell
        
        if indexPath.section == 0 {
            cell.setDataInFeedUpdateCell(feed: unReadFeeds[indexPath.row], indexPath: indexPath, isRead: false)
            
        } else if indexPath.section == 1 {
            cell.setDataInFeedUpdateCell(feed: readFeeds[indexPath.row], indexPath: indexPath, isRead: true)
        }
        
        cell.delegate = self
        
//        for selectedIndex in selectedRowIndices{
//            if indexPath.row == selectedIndex.row {
//                if self.unReadFeeds[indexPath.row].ackFlag! {
//                    cell.setDataInFeedUpdateCell(feed: readFeeds[indexPath.row], indexPath: indexPath, isRead: true)
//
//                } else {
//                    if unReadFeeds[indexPath.row].questionFlag! {
//                        cell.setQuestionsInFeedCell(feed:unReadFeeds[indexPath.row] ,indexPath: indexPath)
//                    }
//                }
//
//            }
//        }
        return cell
    }
    
    
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if cellSelected  && indexPath == self.selectedIndexPath {
          let labelHeight = unReadFeeds[indexPath.row].questions?.first?.question?.heightWithConstrainedWidth(UIScreen.main.bounds.width - 32, font: UIFont.gothamLight(15))
            return labelHeight! + CGFloat(321.0)
        }
        return UITableViewAutomaticDimension
    }
 
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! FeedUpdateCell
        if !confirmAnswerSelected  && indexPath == self.selectedIndexPath  {
            if cellSelected && indexPath == self.selectedIndexPath {
                self.cellSelected = false
                if unReadFeeds[indexPath.row].questionFlag! {
                    cell.setQuestionsInFeedCell(feed:unReadFeeds[indexPath.row] ,indexPath: indexPath)
                    cell.delegate = self
                    
                }
            }
        }
    }    
}

// MARK: - FeedUpdateCellDelegate
extension FeedsViewController: FeedUpdateCellDelegate{
    func markAsReadTapped(indexPath: IndexPath, isFromConfirm: Bool) {

        self.selectedIndexPath = indexPath
        if isFromConfirm {
            feedsTableView.reloadRows(at: [indexPath], with: .automatic)
            self.cellSelected = false
            let feedStatusId = unReadFeeds[indexPath.row].notificationId
            self.markAsReadTapped(notId: feedStatusId!, indexPath: indexPath)
            
        } else {
            
            self.cellSelected = true
            feedsTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        self.selectedRowIndices.append(indexPath)
    }
    
    func imageButtonTapped(indexPath: IndexPath, feed: Feed) {
        if indexPath.row == 0 {
            self.feedImageUrl = Constants.ImageUrl.LargeImage + feed.feedsImage!
            self.showImageView(feedImageUrl: feed.feedsImage!)
            self.showAnimate()
        } else if indexPath.row == 1 {
            self.playLocalVideo(feed: feed)
        }
    }
 
    func playLocalVideo(feed: Feed) {
        let videoURL = URL(string: Constants.ImageUrl.Video + feed.feedsVideo!)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}

// MARK: - API Calls
extension FeedsViewController {
    
    func getFeedsList() {
        self.feedsTableView.tableFooterView = totalPages == self.currentPageNumber ? self.indicatorFooter : UIView()
        Helper.showLoader()
        FeedService.getFeedsList(currentPageNumber) { (success, message, resultArray, resultCount, pageCount) -> Void in
            self.isInProgress = false
            Helper.hideLoader()
            
            if let _ = self.feedsTableView.infiniteScrollingView {
                self.feedsTableView.infiniteScrollingView.stopAnimating()
            }
            
            if success {
                print("Feeds fetched from server")
                self.totalPages = pageCount
                self.feedsTableView.backgroundColor = UIColor.black
                
                if self.isPullToRefresh {
                    self.isPullToRefresh = false
                    if self.feedsArray.count > 0 {
                        self.feedsArray.removeAllObjects()
                    }
                }
                
                if (resultArray?.count)! > 0 {
                    for arrayObj in resultArray! {
                        self.feedsArray.add(arrayObj)
                    }
                     self.prepareAcknowledgementArray()
                    self.feedsTableView.reloadData()
                }
            }
            if let _ = self.feedsTableView.pullToRefreshView {
                self.feedsTableView.pullToRefreshView.stopAnimating()
            }
        }
    }
    
    func pullToRefresh() {
        self.feedsTableView.addPullToRefresh {
            self.currentPageNumber = 1
            self.isPullToRefresh = true
            self.unReadFeeds.removeAll()
            self.readFeeds.removeAll()
            self.feedsArray.removeAllObjects()
            self.getFeedsList()
        }
    }
    
    // Pagination in listing
    func loadMorePages() {
        self.feedsTableView.addInfiniteScrolling {
            if !self.isInProgress && self.currentPageNumber <= self.totalPages {
                self.currentPageNumber = self.currentPageNumber + 1
                self.isInProgress = true
                self.getFeedsList()
            } else {
                if let _ = self.feedsTableView.infiniteScrollingView {
                    self.feedsTableView.infiniteScrollingView.stopAnimating()
                }
            }
        }
    }

    func markAsReadTapped(notId: Int, indexPath: IndexPath){
        FeedService.getMarkAsRead(notId) { (success, message) in
            if success{
            self.unReadFeeds[indexPath.row].ackFlag = true
            self.manageReadAndUnreadData(index: indexPath)
            } else {
                
            }
        }
    }
    
}

// MARK: - image methods
extension FeedsViewController {
    
    func showImageView(feedImageUrl : String) {
        let imageUrl: String = Constants.ImageUrl.LargeImage + feedImageUrl
        feedImageView.sd_setShowActivityIndicatorView(true)
        feedImageView.sd_setIndicatorStyle(.gray)
        feedImageView.sd_setImage(with: URL(string: imageUrl))
        feedImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "feedPlaceholder"), options: .retryFailed, completed: { image, error, _, url in
            self.feedImageView.image = image!
            self.feedImageView.sd_setShowActivityIndicatorView(false)
        })
    }
    
    func showAnimate() {
        self.feedShowImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.feedShowImageView.isHidden = false
        self.feedShowImageView.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            self.feedShowImageView.alpha = 1
            self.feedShowImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
            self.feedShowImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.feedShowImageView.alpha = 0.0
        }, completion: {(_ finished: Bool) -> Void in
            if finished {
                self.feedShowImageView.isHidden = true
            }
        })
    }
}
