//
//  Feed.swift
//
//  Created by Narender Kumar on 25/05/17
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class Feed: NSObject, NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let content = "content"
    static let createdOn = "createdOn"
    static let dateWiseFlag = "dateWiseFlag"
    static let feedsId = "feedsId"
    static let ackFlag = "ackFlag"
    static let feedsVideo = "feedsVideo"
    static let title = "title"
    static let questionFlag = "questionFlag"
    static let notificationId = "notificationId"
    static let questions = "feedQuestion"
    static let feedStatus = "feedStatus"
    static let feedsImage = "feedsImage"
    static let feedInterval = "feedInterval"
  }

  // MARK: Properties
  public var content: String?
  public var createdOn: String?
  public var dateWiseFlag: Bool? = false
  public var feedsId: Int?
  public var ackFlag: Bool? = false
  public var feedsVideo: String?
  public var title: String?
  public var questionFlag: Bool? = false
  public var notificationId: Int?
  public var questions: [Question]?
  public var feedStatus: Int?
  public var feedsImage: String?
  public var feedInterval: String?
    
    
    override init() {
        super.init()
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
    content = json[SerializationKeys.content].string
    createdOn = json[SerializationKeys.createdOn].string
    dateWiseFlag = json[SerializationKeys.dateWiseFlag].boolValue
    feedsId = json[SerializationKeys.feedsId].int
    ackFlag = json[SerializationKeys.ackFlag].boolValue
    feedsVideo = json[SerializationKeys.feedsVideo].string
    title = json[SerializationKeys.title].string
    questionFlag = json[SerializationKeys.questionFlag].boolValue
    notificationId = json[SerializationKeys.notificationId].int
    if let items = json[SerializationKeys.questions].array { questions = items.map { Question(json: $0) } }
    feedStatus = json[SerializationKeys.feedStatus].int
    feedsImage = json[SerializationKeys.feedsImage].string
    feedInterval = json[SerializationKeys.feedInterval].string
  }
    
    
    public convenience init(info: FeedInfo) {
        self.init()
        
        content = info.desc
        createdOn = Helper.stringFrom(date: info.dateTime!, format: "")
        feedsId = Int(info.id)
        ackFlag = info.isMarkedRead
        feedsVideo = info.videoUrl
        feedsImage = info.imageUrl
        title = info.title
        questionFlag = info.questionFlag
        feedInterval = "\(info.interval)" //FIXME: remove string and assign integer
        //questions =
        //notificationId =
        //items =
        //feedStatus =
        //dateWiseFlag =
    }


  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = content { dictionary[SerializationKeys.content] = value }
    if let value = createdOn { dictionary[SerializationKeys.createdOn] = value }
    dictionary[SerializationKeys.dateWiseFlag] = dateWiseFlag
    if let value = feedsId { dictionary[SerializationKeys.feedsId] = value }
    dictionary[SerializationKeys.ackFlag] = ackFlag
    if let value = feedsVideo { dictionary[SerializationKeys.feedsVideo] = value }
    if let value = title { dictionary[SerializationKeys.title] = value }
    dictionary[SerializationKeys.questionFlag] = questionFlag
    if let value = notificationId { dictionary[SerializationKeys.notificationId] = value }
    if let value = questions { dictionary[SerializationKeys.questions] = value.map { $0.dictionaryRepresentation() } }
    if let value = feedStatus { dictionary[SerializationKeys.feedStatus] = value }
    if let value = feedsImage { dictionary[SerializationKeys.feedsImage] = value }
    if let value = feedInterval { dictionary[SerializationKeys.feedInterval] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.content = aDecoder.decodeObject(forKey: SerializationKeys.content) as? String
    self.createdOn = aDecoder.decodeObject(forKey: SerializationKeys.createdOn) as? String
    self.dateWiseFlag = aDecoder.decodeBool(forKey: SerializationKeys.dateWiseFlag)
    self.feedsId = aDecoder.decodeObject(forKey: SerializationKeys.feedsId) as? Int
    self.ackFlag = aDecoder.decodeBool(forKey: SerializationKeys.ackFlag)
    self.feedsVideo = aDecoder.decodeObject(forKey: SerializationKeys.feedsVideo) as? String
    self.title = aDecoder.decodeObject(forKey: SerializationKeys.title) as? String
    self.questionFlag = aDecoder.decodeBool(forKey: SerializationKeys.questionFlag)
    self.notificationId = aDecoder.decodeObject(forKey: SerializationKeys.notificationId) as? Int
    self.questions = aDecoder.decodeObject(forKey: SerializationKeys.questions) as? [Question]
    self.feedStatus = aDecoder.decodeObject(forKey: SerializationKeys.feedStatus) as? Int
    self.feedsImage = aDecoder.decodeObject(forKey: SerializationKeys.feedsImage) as? String
    self.feedInterval = aDecoder.decodeObject(forKey: SerializationKeys.feedInterval) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(content, forKey: SerializationKeys.content)
    aCoder.encode(createdOn, forKey: SerializationKeys.createdOn)
    aCoder.encode(dateWiseFlag, forKey: SerializationKeys.dateWiseFlag)
    aCoder.encode(feedsId, forKey: SerializationKeys.feedsId)
    aCoder.encode(ackFlag, forKey: SerializationKeys.ackFlag)
    aCoder.encode(feedsVideo, forKey: SerializationKeys.feedsVideo)
    aCoder.encode(title, forKey: SerializationKeys.title)
    aCoder.encode(questionFlag, forKey: SerializationKeys.questionFlag)
    aCoder.encode(notificationId, forKey: SerializationKeys.notificationId)
    aCoder.encode(questions, forKey: SerializationKeys.questions)
    aCoder.encode(feedStatus, forKey: SerializationKeys.feedStatus)
    aCoder.encode(feedsImage, forKey: SerializationKeys.feedsImage)
    aCoder.encode(feedInterval, forKey: SerializationKeys.feedInterval)
  }

}
