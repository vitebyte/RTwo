//
//  Question.swift
//
//  Created by Narender Kumar on 20/04/17
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public class Question: NSObject, NSCoding {

    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let options = "options"
        static let questionId = "questionId"
        static let question = "question"
    }

    // MARK: Properties
    public var options: [Options]?
    public var questionId: Int?
    public var question: String?

    override init() {
        // initialization
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
        if let items = json[SerializationKeys.options].array { options = items.map { Options(json: $0) } }
        questionId = json[SerializationKeys.questionId].int
        question = json[SerializationKeys.question].string
    }

    public convenience init(quesinfo: QuestionInfo) {
        self.init()
        questionId = Int(quesinfo.id)
        question = quesinfo.info

        var optionsArray: [Options] = [Options]()
        if let answers = quesinfo.answersInfo {
            for optionInfo in answers {
                optionsArray.append(Options(ansinfo: optionInfo as! AnswerInfo))
            }

            options = optionsArray
        }
    }

    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = options { dictionary[SerializationKeys.options] = value.map { $0.dictionaryRepresentation() } }
        if let value = questionId { dictionary[SerializationKeys.questionId] = value }
        if let value = question { dictionary[SerializationKeys.question] = value }
        return dictionary
    }

    // MARK: NSCoding Protocol
    public required init(coder aDecoder: NSCoder) {
        options = aDecoder.decodeObject(forKey: SerializationKeys.options) as? [Options]
        questionId = aDecoder.decodeObject(forKey: SerializationKeys.questionId) as? Int
        question = aDecoder.decodeObject(forKey: SerializationKeys.question) as? String
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(options, forKey: SerializationKeys.options)
        aCoder.encode(questionId, forKey: SerializationKeys.questionId)
        aCoder.encode(question, forKey: SerializationKeys.question)
    }
}
