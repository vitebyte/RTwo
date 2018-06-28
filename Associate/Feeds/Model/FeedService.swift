//
//  FeedService.swift
//  DigitalEcoSystem
//
//  Created by Ravi Ranjan on 25/05/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit

class FeedService: NSObject {
    // MARK: - Get Feeds List
    class func getFeedsList(_ pageNumber: Int, completionHandler: @escaping (_ success: Bool, _ message: String?, _ resultArray: [Feed]?, _ resultCount: Int, _ pageCount: Int) -> Void) {
        
        let DEFAULT_VALUE: Int = 1
        
        guard NetworkManager.isNetworkReachable() else {
            completionHandler(false, Helper.noInternetConnection().localizedFailureReason, nil, 0, 0)
            return
        }
        
        let headers = Helper.defaultServiceHeaders
        let urlString: String = NSString(format: Constants.APIServiceMethods.feedsListAPI as NSString, "\(pageNumber)", "\(pageNumber)") as String
        NetworkManager.requestGETURL(urlString, headers: headers, success: { responseJSON in
            let responseDictionary = responseJSON.dictionaryObject
            if responseDictionary != nil {
                let isSuccess = responseDictionary?[Constants.APIKEYS.SUCCESS] as! Bool
                let message = responseDictionary?[Constants.APIKEYS.MESSAGE] as! String
                if isSuccess {
                    var resultCount: Int = DEFAULT_VALUE
                    var pageCount: Int = DEFAULT_VALUE
                    let resultDictionary = responseDictionary?[Constants.APIKEYS.DATA] as! NSDictionary
                    print(resultDictionary)
                    if let feedArray: NSArray = resultDictionary.value(forKey: Constants.APIKEYS.CONTENTLIST) as? NSArray {
                        var feedList: [Feed]? = [Feed]()
                        for feed in feedArray {
                            let tempFeed = Feed(object: feed)
                            feedList?.append(tempFeed)
                        }
                        
                        /*CoreDataManager.cacheFeeds(availableFeeds: feedList!, completionHandler: { (success) in
                            print("feeds cached in core data")
                        })*/
                        
                        if let resultCountVal: Int = resultDictionary[Constants.APIKEYS.NUMBER_OF_RESULTS] as? Int {
                            resultCount = resultCountVal
                        }
                        if let pageCountValue: Int = resultDictionary[Constants.APIKEYS.TOTAL_PAGES] as? Int {
                            pageCount = pageCountValue
                        }
                        completionHandler(true, message, feedList, resultCount, pageCount)
                    } else {
                        completionHandler(true, message, nil, DEFAULT_VALUE, DEFAULT_VALUE)
                    }
                } else {
                    completionHandler(false, message, nil, DEFAULT_VALUE, DEFAULT_VALUE)
                    LogManager.logError("Error occurred while getting feed list\(message)")
                }
            } else {
                completionHandler(false, "couldn't parse the response", nil, DEFAULT_VALUE, DEFAULT_VALUE)
                LogManager.logError("Error occurred while parsing of data for feed list")
            }
        }) { error in
            ErrorManager.handleError(error)
            completionHandler(false, error.localizedDescription, nil, DEFAULT_VALUE, DEFAULT_VALUE)
        }
    }
    
    // MARK: - MarkAsRead Tapped
    
    class func getMarkAsRead(_ notId: Int, completionHandler: @escaping (_ success: Bool, _ message: String) -> Void) {
        
        guard NetworkManager.isNetworkReachable() else {
            completionHandler(false, Helper.noInternetConnection().localizedFailureReason!)
            return
        }
        
        let headers = Helper.defaultServiceHeaders
        let urlString: String = NSString(format: Constants.APIServiceMethods.markAsReadAPI as NSString, "\(notId)") as String
        NetworkManager.requestGETURL(urlString, headers: headers, success: { responseJSON in
            let responseDictionary = responseJSON.dictionaryObject
            if responseDictionary != nil {
                let isSuccess = responseDictionary?[Constants.APIKEYS.SUCCESS] as! Bool
                let message = responseDictionary?[Constants.APIKEYS.MESSAGE] as! String
                if isSuccess {
                    let resultDictionary = responseDictionary?[Constants.APIKEYS.DATA] as! NSDictionary
                    print(resultDictionary)
                     completionHandler(true, message)
                } else {
                    completionHandler(false, message)
                    LogManager.logError("Error occurred while get mark as read \(message)")
                }
            } else {
                completionHandler(false, "couldn't parse the response")
                LogManager.logError("Error occurred while parsing get mark as read)")
            }
        }) { error in
            ErrorManager.handleError(error)
            completionHandler(false, error.localizedDescription)
        }
    }


}
