//
//  TrainingQuestion+Services.swift
//  DigitalEcoSystem
//
//  Created by Narender Kumar on 10/04/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

extension Question {

    //MARK : - get training questions
    class func getTrainingQuestions(_ training: Training, completionHandler: @escaping (_ success: Bool, _ message: String?, _ resultArray: [Question]?) -> Void) {

        guard NetworkManager.isNetworkReachable() else {
            let quizList = CoreDataManager.loadQuiz(forTraining: (training.trainingId)!)
            completionHandler(true, nil, quizList)
            return
        }

        let headers = Helper.defaultServiceHeaders

        let urlString: String = NSString(format: Constants.APIServiceMethods.trainingQuiz as NSString, "\(training.trainingId!)") as String
        NetworkManager.requestGETURL(urlString, headers: headers, success: { responseJSON in
            let responseDictionary = responseJSON.dictionaryObject
            if responseDictionary != nil {
                let isSuccess = responseDictionary?[Constants.APIKEYS.SUCCESS] as! Bool
                let message = responseDictionary?[Constants.APIKEYS.MESSAGE] as! String
                if isSuccess {
                    if let questionArray: NSArray = responseDictionary?[Constants.APIKEYS.DATA] as? NSArray {
                        var questionList: [Question]? = [Question]()
                        for question in questionArray {
                            let trainingObject = Question(object: question)
                            questionList?.append(trainingObject)
                        }

                        // save training to coredata
                        CoreDataManager.cacheQuiz(questions: questionList!, for: training)
                        completionHandler(true, message, questionList)
                    } else {
                        completionHandler(false, message, nil)
                        LogManager.logError("Error occurred getting training questions \(message)")
                    }
                } else {
                    completionHandler(false, message, nil)
                    LogManager.logError("Error occurred while getting training questions \(message)")
                }
            } else {
                completionHandler(false, "couldn't parse the response", nil)
                LogManager.logError("Error occurred while parsing received data for training questions")
            }
        }) { error in
            Helper.hideLoader()
            ErrorManager.handleError(error)
            completionHandler(false, error.localizedDescription, nil)
        }
    }
}
