//
//  Training.swift
//
//  Created by Narender Kumar on 22/04/17
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

enum TrainingStatus: NSNumber {
    case New = 0
    case InProgress = 1
    case Completed = 2
    case Expired = 3
}

public class Training: NSObject, NSCoding {

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let langCode = "langCode"
        static let completedPer = "completedPer"
        static let quizResult = "quizResult"
        static let trainingTitle = "trainingTitle"
        static let status = "status"
        static let trainingDate = "trainingDate"
        static let videoUrl = "videoUrl"
        static let trainingId = "trainingId"
        static let completedFlag = "completedFlag"
        static let activeFlag = "activeFlag"
        static let attemptLeft = "attemptLeft"
        static let imageUrl = "imageUrl"
        static let trainingContent = "trainingContent"
        static let categoryName = "categoryName"
        static let publishFlag = "publishFlag"
    }

    // MARK: Properties
    public var langCode: Int?
    public var completedPer: Int?
    public var quizResult: Int?
    public var trainingTitle: String?
    public var status: Int?
    public var trainingDate: String?
    public var videoUrl: String?
    public var trainingId: Int?
    public var completedFlag: Bool? = false
    public var activeFlag: Bool? = false
    public var attemptLeft: Int?
    public var imageUrl: String?
    public var trainingContent: String?
    public var categoryName: String?
    public var publishFlag: Bool? = false

    // Videoplayer time-interval
    public var playbackInterval: Double! = 0.0

    override init() {
        // initialization
    }

    // MARK: SwiftyJSON Initializers
    /// Initiates the instance based on the object.
    ///
    /// - parameter object: The object of either Dictionary or Array kind that was passed.
    /// - returns: An initialized instance of the class.
    public convenience init(object: Any) {
        self.init(json: JSON(object))
    }

    /// Initiates the instance based on the JSON that was passed.
    ///
    /// - parameter json: JSON object from SwiftyJSON.
    public required init(json: JSON) {
        langCode = json[SerializationKeys.langCode].int
        completedPer = json[SerializationKeys.completedPer].int
        quizResult = json[SerializationKeys.quizResult].int
        trainingTitle = json[SerializationKeys.trainingTitle].string
        status = json[SerializationKeys.status].int
        trainingDate = json[SerializationKeys.trainingDate].string
        videoUrl = json[SerializationKeys.videoUrl].string
        trainingId = json[SerializationKeys.trainingId].int
        completedFlag = json[SerializationKeys.completedFlag].boolValue
        activeFlag = json[SerializationKeys.activeFlag].boolValue
        attemptLeft = json[SerializationKeys.attemptLeft].int
        imageUrl = json[SerializationKeys.imageUrl].string
        trainingContent = json[SerializationKeys.trainingContent].string
        categoryName = json[SerializationKeys.categoryName].string
        publishFlag = json[SerializationKeys.publishFlag].boolValue
    }

    public convenience init(info: TrainingInfo) {
        self.init()

        trainingId = Int(info.id)
        trainingTitle = info.title
        trainingContent = info.desc
        imageUrl = info.imageUrl
        videoUrl = info.videoUrl
        categoryName = info.category
        completedPer = Int(info.percentCompleted)
        status = Int(info.status)
        attemptLeft = Int(info.remainingAttempts)
        playbackInterval = info.playbackInterval
        quizResult = Int((info.quizInfo?.resultPercentage)!)
    }

    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = langCode { dictionary[SerializationKeys.langCode] = value }
        if let value = completedPer { dictionary[SerializationKeys.completedPer] = value }
        if let value = quizResult { dictionary[SerializationKeys.quizResult] = value }
        if let value = trainingTitle { dictionary[SerializationKeys.trainingTitle] = value }
        if let value = status { dictionary[SerializationKeys.status] = value }
        if let value = trainingDate { dictionary[SerializationKeys.trainingDate] = value }
        if let value = videoUrl { dictionary[SerializationKeys.videoUrl] = value }
        if let value = trainingId { dictionary[SerializationKeys.trainingId] = value }
        dictionary[SerializationKeys.completedFlag] = completedFlag
        dictionary[SerializationKeys.activeFlag] = activeFlag
        if let value = attemptLeft { dictionary[SerializationKeys.attemptLeft] = value }
        if let value = imageUrl { dictionary[SerializationKeys.imageUrl] = value }
        if let value = trainingContent { dictionary[SerializationKeys.trainingContent] = value }
        if let value = categoryName { dictionary[SerializationKeys.categoryName] = value }
        dictionary[SerializationKeys.publishFlag] = publishFlag
        return dictionary
    }

    // MARK: NSCoding Protocol
    public required init(coder aDecoder: NSCoder) {
        langCode = aDecoder.decodeObject(forKey: SerializationKeys.langCode) as? Int
        completedPer = aDecoder.decodeObject(forKey: SerializationKeys.completedPer) as? Int
        quizResult = aDecoder.decodeObject(forKey: SerializationKeys.quizResult) as? Int
        trainingTitle = aDecoder.decodeObject(forKey: SerializationKeys.trainingTitle) as? String
        status = aDecoder.decodeObject(forKey: SerializationKeys.status) as? Int
        trainingDate = aDecoder.decodeObject(forKey: SerializationKeys.trainingDate) as? String
        videoUrl = aDecoder.decodeObject(forKey: SerializationKeys.videoUrl) as? String
        trainingId = aDecoder.decodeObject(forKey: SerializationKeys.trainingId) as? Int
        completedFlag = aDecoder.decodeBool(forKey: SerializationKeys.completedFlag)
        activeFlag = aDecoder.decodeBool(forKey: SerializationKeys.activeFlag)
        attemptLeft = aDecoder.decodeObject(forKey: SerializationKeys.attemptLeft) as? Int
        imageUrl = aDecoder.decodeObject(forKey: SerializationKeys.imageUrl) as? String
        trainingContent = aDecoder.decodeObject(forKey: SerializationKeys.trainingContent) as? String
        categoryName = aDecoder.decodeObject(forKey: SerializationKeys.categoryName) as? String
        publishFlag = aDecoder.decodeBool(forKey: SerializationKeys.publishFlag)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(langCode, forKey: SerializationKeys.langCode)
        aCoder.encode(completedPer, forKey: SerializationKeys.completedPer)
        aCoder.encode(quizResult, forKey: SerializationKeys.quizResult)
        aCoder.encode(trainingTitle, forKey: SerializationKeys.trainingTitle)
        aCoder.encode(status, forKey: SerializationKeys.status)
        aCoder.encode(trainingDate, forKey: SerializationKeys.trainingDate)
        aCoder.encode(videoUrl, forKey: SerializationKeys.videoUrl)
        aCoder.encode(trainingId, forKey: SerializationKeys.trainingId)
        aCoder.encode(completedFlag, forKey: SerializationKeys.completedFlag)
        aCoder.encode(activeFlag, forKey: SerializationKeys.activeFlag)
        aCoder.encode(attemptLeft, forKey: SerializationKeys.attemptLeft)
        aCoder.encode(imageUrl, forKey: SerializationKeys.imageUrl)
        aCoder.encode(trainingContent, forKey: SerializationKeys.trainingContent)
        aCoder.encode(categoryName, forKey: SerializationKeys.categoryName)
        aCoder.encode(publishFlag, forKey: SerializationKeys.publishFlag)
    }
}
