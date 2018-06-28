//
//  Options.swift
//
//  Created by Narender Kumar on 20/04/17
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class Options: NSObject, NSCoding {

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let answer = "answer"
        static let answerFlag = "answerFlag"
        static let answerId = "answerId"
    }

    // MARK: Properties
    public var answer: String?
    public var answerFlag: Bool? = false
    public var answerId: Int?

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
        answer = json[SerializationKeys.answer].string
        answerFlag = json[SerializationKeys.answerFlag].boolValue
        answerId = json[SerializationKeys.answerId].int
    }

    public convenience init(ansinfo: AnswerInfo) {
        self.init()

        answerId = Int(ansinfo.id)
        answer = ansinfo.info
        answerFlag = ansinfo.isCorrect
    }

    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = answer { dictionary[SerializationKeys.answer] = value }
        dictionary[SerializationKeys.answerFlag] = answerFlag
        if let value = answerId { dictionary[SerializationKeys.answerId] = value }
        return dictionary
    }

    // MARK: NSCoding Protocol
    public required init(coder aDecoder: NSCoder) {
        answer = aDecoder.decodeObject(forKey: SerializationKeys.answer) as? String
        answerFlag = aDecoder.decodeBool(forKey: SerializationKeys.answerFlag)
        answerId = aDecoder.decodeObject(forKey: SerializationKeys.answerId) as? Int
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(answer, forKey: SerializationKeys.answer)
        aCoder.encode(answerFlag, forKey: SerializationKeys.answerFlag)
        aCoder.encode(answerId, forKey: SerializationKeys.answerId)
    }
}
