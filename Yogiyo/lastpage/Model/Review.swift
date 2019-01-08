//
//  Review.swift
//  TableViewYogiyo
//
//  Created by 김지훈 on 10/12/2018.
//  Copyright © 2018 Kira. All rights reserved.
//





// MARK: Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

import Foundation

typealias Review = [ReviewElement]

struct ReviewElement: Codable {
    let id: Int
    let comment: String
    let rating: Double
    let ratingDelivery, ratingQuantity, ratingTaste: String
    let reviewImages: JSONNull?
    let time: String
    let user: User
    let menuSummary: [MenuSummary]
    let restaurant: Int
    
    var otherRating: String {
        return "맛: \(ratingTaste), 양: \(ratingQuantity), 배달: \(ratingDelivery)"
    }
    
    var changeTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSSSSSZZZZZZ"
        print(time)
        if let date = formatter.date(from: time) {
            print("date", date)
            let now = Date()
            let interval = now.timeIntervalSince(date)
            if interval < 86400 {
                return "\(Int(interval/3600)) 시간 전"
            } else {
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: date)
            }
            
        } else {
            print("fail")
            return ""
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, comment, rating
        case ratingDelivery = "rating_delivery"
        case ratingQuantity = "rating_quantity"
        case ratingTaste = "rating_taste"
        case reviewImages = "review_images"
        case time, user
        case menuSummary = "menu_summary"
        case restaurant
    }
}

struct MenuSummary: Codable {
    let id: Int
    let image: String?
    let name: String
    let price: Int
}

struct User: Codable {
    let id: Int
    let username, email, phoneNumber: String
    let nickName: String
    
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case phoneNumber = "phone_number"
        case nickName = "nick_name"
    }
}

// MARK: Encode/decode helpers



