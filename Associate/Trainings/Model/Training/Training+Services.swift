//
//  Training+Services.swift
//  DigitalEcoSystem
//
//  Created by Shafi Ahmed on 08/03/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import Foundation

extension Training {
    
    // MARK: - Get Trainings
    class func loadTrainings(_ categoryId:Int, subcategoryId:Int, pageNumber: Int, completionHandler: @escaping (_ success: Bool, _ message: String?, _ resultArray: [Training]?, _ resultCount: Int, _ pageCount: Int) -> Void) {
        
        var category_Id = categoryId
        if category_Id == -1 {
            category_Id = 0
        }
        var subcategory_Id = subcategoryId
        if subcategory_Id == 0 {
            subcategory_Id = 0
        }

        let DEFAULT_VALUE: Int = 1

        guard NetworkManager.isNetworkReachable() else {
            let trainingList = CoreDataManager.loadTrainings()
            completionHandler(true, nil, trainingList, 0, 0)
            return
        }

        let headers = Helper.defaultServiceHeaders

        let urlString: String = NSString(format: Constants.APIServiceMethods.traningListAPI as NSString,"\(category_Id)","\(subcategory_Id)", "\(pageNumber)") as String

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
                }
            } else {
                completionHandler(false, "couldn't parse the response", nil, DEFAULT_VALUE, DEFAULT_VALUE)
            }
        }) { error in
            Helper.hideLoader()
            ErrorManager.handleError(error)
            completionHandler(false, error.localizedDescription, nil, DEFAULT_VALUE, DEFAULT_VALUE)
        }
    }

    //MARK: - assign trainings
    class func assignTraining(_ traineeIds: AnyObject, traningIds: AnyObject, trainerId: Int, storeId: Int, completionHandler: @escaping (_ success: Bool, _ message: String?) -> Void) {

        guard NetworkManager.isNetworkReachable() else {
            completionHandler(false, Helper.noInternetConnection().localizedFailureReason)
            return
        }

        let headers = Helper.defaultServiceHeaders

        var params = Helper.defaultServiceParameters
        params[Constants.APIKEYS.TRAINEE_IDS] = traineeIds
        params[Constants.APIKEYS.TRANING_IDS] = traningIds
        params[Constants.APIKEYS.TRAINER_ID] = trainerId
        params[Constants.APIKEYS.STORE_ID] = storeId

        let url = Constants.APIServiceMethods.assignTrainingsAPI
        NetworkManager.requestPOSTURL(url, params: params as [String: AnyObject]?, headers: headers, success: { responseJSON in
            Helper.hideLoader()
            let responseDictionary = responseJSON.dictionaryObject
            if responseDictionary != nil {
                let isSuccess = responseDictionary?[Constants.APIKEYS.SUCCESS] as! Bool
                let message = responseDictionary?[Constants.APIKEYS.MESSAGE] as! String
                if isSuccess {
                    completionHandler(true, message)
                } else {
                    completionHandler(false, message)
                    LogManager.logError("Error occurred while assigning training")
                }
            } else {
                completionHandler(false, "Error")
                LogManager.logError("Error occurred while assigningi training")
            }

        }) { error in
            Helper.hideLoader()
            ErrorManager.handleError(error)
            completionHandler(false, error.localizedDescription)
        }
    }

    //MARK: - Update training video time on server
    class func syncTrainingVideoTime(_ traningIds: AnyObject, videoTime: Float, completionHandler: @escaping (_ success: Bool, _ message: String?) -> Void) {
        
        guard NetworkManager.isNetworkReachable() else {
            completionHandler(false, Helper.noInternetConnection().localizedFailureReason)
            return
        }
        
        let headers = Helper.defaultServiceHeaders
        
        let urlString: String = NSString(format: Constants.APIServiceMethods.syncTrainingVideo as NSString, "\(traningIds)", "\(videoTime)") as String
        NetworkManager.requestGETURL(urlString, headers: headers, success: { responseJSON in
            let responseDictionary = responseJSON.dictionaryObject
            if responseDictionary != nil {
                let isSuccess = responseDictionary?[Constants.APIKEYS.SUCCESS] as! Bool
                let message = responseDictionary?[Constants.APIKEYS.MESSAGE] as! String
                if isSuccess {
                    completionHandler(true, message)
                } else {
                    completionHandler(false, message)
                    LogManager.logError("Error occurred while sync training video time\(message)")
                }
            } else {
                completionHandler(false, "couldn't parse the response")
                LogManager.logError("Error occurred while parsing of syn training video time")
            }
        }) { error in
            Helper.hideLoader()
            ErrorManager.handleError(error)
            completionHandler(false, error.localizedDescription)
        }
    }
    
    
    //MARK: - Update training question index on server
    class func syncTrainingQuizIndex(_ traningIds: AnyObject, questionIndex: Int, storeId: Int, completionHandler: @escaping (_ success: Bool, _ message: String?) -> Void) {
        
        guard NetworkManager.isNetworkReachable() else {
            completionHandler(false, Helper.noInternetConnection().localizedFailureReason)
            return
        }
        
        let headers = Helper.defaultServiceHeaders
        
        let urlString: String = NSString(format: Constants.APIServiceMethods.syncTrainingQuestion as NSString, "\(traningIds)", "\(questionIndex)") as String
        NetworkManager.requestGETURL(urlString, headers: headers, success: { responseJSON in
            let responseDictionary = responseJSON.dictionaryObject
            if responseDictionary != nil {
                let isSuccess = responseDictionary?[Constants.APIKEYS.SUCCESS] as! Bool
                let message = responseDictionary?[Constants.APIKEYS.MESSAGE] as! String
                if isSuccess {
                    completionHandler(true, message)
                } else {
                    completionHandler(false, message)
                    LogManager.logError("Error occurred while syncing training quiz index \(message)")
                }
            } else {
                completionHandler(false, "couldn't parse the response")
                LogManager.logError("Error occurred while parsing of syncing training quiz index")
            }
        }) { error in
            Helper.hideLoader()
            ErrorManager.handleError(error)
            completionHandler(false, error.localizedDescription)
        }
    }
    
    //MARK: - sync training result
    class func syncTrainingResult(_ answerArray: [AnyObject], trainingId: Int, completionHandler: @escaping (_ success: Bool, _ message: String?) -> Void) {

        guard NetworkManager.isNetworkReachable() else {
            completionHandler(false, Helper.noInternetConnection().localizedFailureReason)
            return
        }

        let headers = Helper.defaultServiceHeaders
        let params = [
            Constants.APIKEYS.TRAINING_ID: trainingId,
            Constants.APIKEYS.USER_ANSWERS: answerArray,
        ] as [String: Any]

        let url = Constants.APIServiceMethods.syncTrainingResult
        NetworkManager.requestPOSTURL(url, params: params as [String: AnyObject]?, headers: headers, success: { responseJSON in
            let responseDictionary = responseJSON.dictionaryObject
            if responseDictionary != nil {
                let isSuccess = responseDictionary?[Constants.APIKEYS.SUCCESS] as! Bool
                let message = responseDictionary?[Constants.APIKEYS.MESSAGE] as! String
                if isSuccess {
                    completionHandler(true, message)
                } else {
                    completionHandler(false, message)
                    LogManager.logError("Error occurred while syncing training result\(message)")
                }
            } else {
                completionHandler(false, "Error")
                LogManager.logError("Error occurred while syncing training result")
            }

        }) { error in
            Helper.hideLoader()
            ErrorManager.handleError(error)
            completionHandler(false, error.localizedDescription)
        }
    }
}
