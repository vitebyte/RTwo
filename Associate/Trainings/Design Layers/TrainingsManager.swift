//
//  TrainingsManager.swift
//  DigitalEcoSystem
//
//  Created by Shafi Ahmed on 08/05/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import UIKit
import CTVideoPlayerView

protocol TrainingsManagerDelegate {
    func trainingsLoaded(_ arrayTrainings: [Training])
}

class TrainingsManager: NSObject {

    // MARK: - Variables
    var delegate: TrainingsManagerDelegate?
    private static let _sharedManager = TrainingsManager()

    // MARK: - class methods
    open class var shared: TrainingsManager {
        return _sharedManager
    }

    // MARK: - Initializer
    fileprivate override init() {
        super.init()

        CTVideoManager.sharedInstance().downloadStrategy = .downloadForegroundAndBackground
    }

    // MARK: - get trainings
    func getTrainings(_ catId:Int, subCatId:Int, pageNumber: Int, completionHandler: @escaping (_ success: Bool, _ message: String?, _ resultArray: [Training]?, _ resultCount: Int, _ pageCount: Int) -> Void) {
        
        var categoryId = catId
        if categoryId == -1 {
            categoryId = 0
        }
        var subCategoryId = subCatId
        if subCategoryId == -1 {
            subCategoryId = 0
        }

        let DEFAULT_VALUE: Int = 1

        guard NetworkManager.isNetworkReachable() else {
            let trainingList = CoreDataManager.loadTrainings()
            completionHandler(true, nil, trainingList, 0, 0)
            return
        }

        let headers = Helper.defaultServiceHeaders

        let urlString: String = NSString(format: Constants.APIServiceMethods.traningListAPI as NSString, "\(categoryId)", "\(subCategoryId)", "\(pageNumber)") as String

        NetworkManager.requestGETURL(urlString, headers: headers, success: { responseJSON in
            let responseDictionary = responseJSON.dictionaryObject
            if responseDictionary != nil {
                let isSuccess = responseDictionary?[Constants.APIKEYS.SUCCESS] as! Bool
                let message = responseDictionary?[Constants.APIKEYS.MESSAGE] as! String
                if isSuccess {
                    var resultCount: Int = DEFAULT_VALUE
                    var pageCount: Int = DEFAULT_VALUE
                    let resultDictionary = responseDictionary?[Constants.APIKEYS.DATA] as! NSDictionary
                    if let trainingDictionary: NSArray = resultDictionary.value(forKey: Constants.APIKEYS.CONTENTLIST) as? NSArray {
                        
                        let tempDictionary = trainingDictionary.firstObject as! NSDictionary
                        let validTrainings: NSArray = (tempDictionary.value(forKey: Constants.APIKEYS.VALID_TRAINING_IDS) as? NSArray)!
                        
                        let trainingDictionary:NSArray = (tempDictionary.value(forKey: Constants.APIKEYS.ALL_TRAINING) as? NSArray)!

                        var trainingList: [Training]? = [Training]()
                        for training in trainingDictionary {
                            let trainingObj = Training(object: training)
                            trainingList?.append(trainingObj)

                            if let validUrl = trainingObj.videoUrl {
                                Helper.downloadVideo(NSURL(string: validUrl) as! URL)
                            }
                        }

                        // save training to coredata
                        CoreDataManager.cacheTrainings(availableTrainings: trainingList!, completionHandler: { (success) in
                            if success {
                                // update coredata with valid training's
                                CoreDataManager.findInvalidTrainings(validTrainings: validTrainings)
                            }
                        })

                        if let resultCountVal: Int = resultDictionary[Constants.APIKEYS.NUMBER_OF_RESULTS] as? Int {
                            resultCount = resultCountVal
                        }
                        if let pageCountValue: Int = resultDictionary[Constants.APIKEYS.TOTAL_PAGES] as? Int {
                            pageCount = pageCountValue
                        }
                        completionHandler(true, message, trainingList, resultCount, pageCount)
                    } else {
                        completionHandler(true, message, nil, DEFAULT_VALUE, DEFAULT_VALUE)
                    }
                } else {
                    completionHandler(false, message, nil, DEFAULT_VALUE, DEFAULT_VALUE)
                    LogManager.logError("Error occurred while getting training \(message)")
                }
            } else {
                completionHandler(false, "couldn't parse the response", nil, DEFAULT_VALUE, DEFAULT_VALUE)
                LogManager.logError("Error occurred while parsing of get trainings")
            }
        }) { error in
            Helper.hideLoader()
            ErrorManager.handleError(error)
            completionHandler(false, error.localizedDescription, nil, DEFAULT_VALUE, DEFAULT_VALUE)
        }
    }

    // MARK: - refresh trainings
    func refreshTrainings() {
        print("Loading trainings from coredata")

        let trainingData = CoreDataManager.loadTrainings()
        if trainingData.count == 0 {
            _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refreshTrainings), userInfo: nil, repeats: false)
        } else {
            delegate?.trainingsLoaded(trainingData)
        }
    }

    // MARK: - Get trainee training
    // As a associate view my trainee training
    func getTraineeTrainings(_ traineeId: Int, _ pageNumber: Int, completionHandler: @escaping (_ success: Bool, _ message: String?, _ resultArray: [Training]?, _ resultCount: Int, _ pageCount: Int) -> Void) {

        let DEFAULT_VALUE: Int = 1

        guard NetworkManager.isNetworkReachable() else {
            let trainingList = CoreDataManager.loadTrainings()
            completionHandler(true, nil, trainingList, 0, 0)
            return
        }

        let headers = Helper.defaultServiceHeaders
        let params = [
            Constants.APIKEYS.TRAINEE_ID: traineeId,
        ] as [String: Any]

        let urlString: String = NSString(format: Constants.APIServiceMethods.traningListAPI as NSString, "\(pageNumber)") as String

        NetworkManager.requestPOSTURL(urlString, params: params as [String: AnyObject]?, headers: headers, success: { responseJSON in
            let responseDictionary = responseJSON.dictionaryObject
            if responseDictionary != nil {
                let isSuccess = responseDictionary?[Constants.APIKEYS.SUCCESS] as! Bool
                let message = responseDictionary?[Constants.APIKEYS.MESSAGE] as! String
                if isSuccess {
                    var resultCount: Int = DEFAULT_VALUE
                    var pageCount: Int = DEFAULT_VALUE
                    let resultDictionary = responseDictionary?[Constants.APIKEYS.DATA] as! NSDictionary
                    if let trainingDictionary: NSArray = resultDictionary.value(forKey: Constants.APIKEYS.CONTENTLIST) as? NSArray {

                        var trainingList: [Training]? = [Training]()
                        for training in trainingDictionary {
                            let trainingObj = Training(object: training)
                            trainingList?.append(trainingObj)
                        }

                        if let resultCountVal: Int = resultDictionary[Constants.APIKEYS.NUMBER_OF_RESULTS] as? Int {
                            resultCount = resultCountVal
                        }
                        if let pageCountValue: Int = resultDictionary[Constants.APIKEYS.TOTAL_PAGES] as? Int {
                            pageCount = pageCountValue
                        }
                        completionHandler(true, message, trainingList, resultCount, pageCount)
                    } else {
                        completionHandler(true, message, nil, DEFAULT_VALUE, DEFAULT_VALUE)
                    }
                } else {
                    completionHandler(false, message, nil, DEFAULT_VALUE, DEFAULT_VALUE)
                    LogManager.logError("Error occurred while get trainee training \(message)")
                }
            } else {
                completionHandler(false, "couldn't parse the response", nil, DEFAULT_VALUE, DEFAULT_VALUE)
                LogManager.logError("Error occurred while parsing of get trainee training")
            }
        }) { error in
            Helper.hideLoader()
            ErrorManager.handleError(error)
            completionHandler(false, error.localizedDescription, nil, DEFAULT_VALUE, DEFAULT_VALUE)
        }
    }

    // MARK: - Update trainee training status
    // As a associate I update my trainee training status (Approve/Reject)
    func traineeTrainingStatusUpdate(_ traineeId: Int, _ tainingId: Int, _ status: Int, completionHandler: @escaping (_ success: Bool, _ message: String?) -> Void) {
        guard NetworkManager.isNetworkReachable() else {
            completionHandler(false, Helper.noInternetConnection().localizedFailureReason)
            return
        }

        let headers = Helper.defaultServiceHeaders
        let params = [
            Constants.APIKEYS.TRAINEE_ID: traineeId,
            Constants.APIKEYS.TRAINING_ID: tainingId,
            Constants.APIKEYS.STATUS: status,
        ] as [String: Any]

        let urlString: String = NSString(format: Constants.APIServiceMethods.traningListAPI as NSString, "\(traineeId)", "\(tainingId)", "\(status)") as String

        NetworkManager.requestPOSTURL(urlString, params: params as [String: AnyObject]?, headers: headers, success: { responseJSON in
            if let responseDictionary = responseJSON.dictionaryObject {
                let isSuccess = responseDictionary[Constants.APIKEYS.SUCCESS] as! Bool
                let message = responseDictionary[Constants.APIKEYS.MESSAGE] as! String
                if isSuccess {
                    completionHandler(true, message)
                } else {
                    completionHandler(false, message)
                    LogManager.logError("Error occurred while trainee training status update \(message)")
                }
            }
        }, failure: { error in
            Helper.hideLoader()
            ErrorManager.handleError(error)
            completionHandler(false, error.localizedDescription)
        })
    }
}
