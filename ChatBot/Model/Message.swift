//
//  Message.swift
//  ChatBot
//
//  Created by Riddhi Makwana on 01/09/21.
//

import Foundation
enum MessageType {
    case user
    case bot
}

enum MessageUI {
    case regular
    case withButtons
}

class Message {
    
    var text: String = ""
    var date: Date
    var type: MessageType
    var UIType : MessageUI
    var options : [ResponseButton]
    
    init(date: Date, type: MessageType , UIType : MessageUI , options : [ResponseButton]) {
        self.date = date
        self.type = type
        self.UIType = UIType
        self.options = options
    }
    
    convenience init(text: String, date: Date, type: MessageType, UIType : MessageUI , options : [ResponseButton]) {
        self.init(date: date, type: type,UIType:UIType , options : options)
        self.text = text
    }
    
    func getImage() -> String {
        switch self.type {
        case .user:
            return "user.png"
        default:
            return "bot.pdf"
        }
    }
    
}

struct ResponseRootClass : Codable {
    
    let buttons : [ResponseButton]?
    let recipientId : String?
    let text : String?
    
    enum CodingKeys: String, CodingKey {
        case buttons = "buttons"
        case recipientId = "recipient_id"
        case text = "text"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        buttons = try values.decodeIfPresent([ResponseButton].self, forKey: .buttons)
        recipientId = try values.decodeIfPresent(String.self, forKey: .recipientId)
        text = try values.decodeIfPresent(String.self, forKey: .text)
    }
    
}
struct ResponseButton : Codable {
    
    let payload : String?
    let title : String?
    
    enum CodingKeys: String, CodingKey {
        case payload = "payload"
        case title = "title"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        payload = try values.decodeIfPresent(String.self, forKey: .payload)
        title = try values.decodeIfPresent(String.self, forKey: .title)
    }
    
}


