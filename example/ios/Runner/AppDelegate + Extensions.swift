//
//  AppDelegate + Extensions.swift
//  Runner
//
//  Created by Pranay on 21/07/21.
//

import UIKit
import CometChatPro

extension AppDelegate : CometChatMessageDelegate{
    func onTextMessageReceived(textMessage: TextMessage) {
        let parsedMsg = self.getMessageMap(message: textMessage)
        print("From textmsg ",parsedMsg) //return parsedMsg obj back to flutter
        
        
      }

      func onMediaMessageReceived(mediaMessage: MediaMessage) {
        let parsedMsg = self.getMessageMap(message: mediaMessage)
        print("From mediaMsg ",parsedMsg)
        
      }
      
      func onCustomMessageReceived(customMessage: CustomMessage) {
        let parsedMsg = self.getMessageMap(message: customMessage)
        print("From customMsg ",parsedMsg)
        
      }
    
    private func getMessageMap(message: BaseMessage?) -> [String: Any]? {
        print(message as Any)
        if let message = message {
            
           // print(message.messageType)
            
            var receiver : [String : Any]?
            var receiverType : String
            //            if let user = message.receiver as? User {
            //                receiver = getUserMap(user: user)
            //            } else if let group = message.receiver as? Group {
            //                receiver = getGroupMap(group: group)
            //            } else {
            //                receiver = nil
            //            }
            switch message.receiverType {
            case .user:
                receiverType = "user"
                receiver = getUserMap(user: message.receiver as? User)
            default:
                receiverType = "group"
                receiver = getGroupMap(group: message.receiver as? Group)
            }
            
            var category : String = "custom"
            switch message.messageCategory {
            case CometChat.MessageCategory.message:
                category = "message"
            case CometChat.MessageCategory.action:
                category = "action"
            case CometChat.MessageCategory.call:
                category = "call"
            default:
                category = "custom"
            }
            
            var type : String = ""
            if category != "action"{
                switch message.messageType {
                case CometChat.MessageType.text:
                    type = "text"
                case CometChat.MessageType.image:
                    type = "image"
                case CometChat.MessageType.video:
                    type = "video"
                case CometChat.MessageType.file:
                    type = "file"
                case CometChat.MessageType.audio:
                    type = "audio"
                default:
                    type = "custom"
                }
            }else{
                type = "action"
            }
            
           
            
            var messageMap = [
                "id" : message.id as Any,
                "muid" : message.muid  as Any,
                "sender" : getUserMap(user: message.sender) as Any,
                "receiver" : receiver as Any,
                "receiverUid" : message.receiverUid as Any,
                "type" : type,
                "receiverType" : receiverType,
                "category" : category,
                "sentAt" : Int(message.sentAt),
                "deliveredAt" : Int(message.deliveredAt),
                "readAt" : Int(message.readAt),
                "metadata" :  toJson(dictionary: message.metaData) as Any,
                "readByMeAt" : Int(message.readByMeAt),
                "deliveredToMeAt" : Int(message.deliveredToMeAt),
                "deletedAt" : Int(message.deletedAt),
                "editedAt" : Int(message.editedAt),
                "deletedBy" : message.deletedBy,
                "editedBy" : message.editedBy,
                "updatedAt" : Int(message.updatedAt),
                "conversationId" : message.conversationId,
                "parentMessageId" : message.parentMessageId,
                "replyCount" : message.replyCount
            ]
            
            if let text = message as? TextMessage {
                let map = [
                    "text" : text.text
                ]
                map.forEach { (key, value) in messageMap[key] = value }
            } else if let media = message as? MediaMessage{
                let map = [
                    "caption" : media.caption as Any,
                    "attachment" : getAttachmentMap(attachment: media.attachment) as Any,
                ]
                map.forEach { (key, value) in messageMap[key] = value }
            } else if let action = message as? ActionMessage{
                let map = [
                    "message" : action.message as Any,
                    "rawData" : action.rawData as Any,
                    "action" : action.action?.rawValue as Any,
                    "oldScope" : action.oldScope.rawValue,
                    "newScope" : action.newScope.rawValue,
                ]
                map.forEach { (key, value) in messageMap[key] = value }
            }
            
            return messageMap;
            
        } else {
            return nil
        }
    }
    
    private func getUserMap(user: User?) -> [String: Any]? {
        print(user as Any)
        if let user = user {
            let status : String
            switch user.status {
            case .online:
                status = "online"
            default:
                status = "offline"
            }
            return [
                "uid" : user.uid ?? "",
                "name" : user.name ?? "",
                "avatar" : user.avatar ?? "",
                "link" : user.link ?? "",
                "role" : user.role ?? "",
                "metadata" : toJson(dictionary: user.metadata) as Any,
                "status" : status,
                "statusMessage" : user.statusMessage ?? "",
                "lastActiveAt" : Int(user.lastActiveAt) ?? 0,
                "tags" : user.tags
            ]
        } else {
            return nil
        }
    }
    
    private func getGroupMap(group: Group?)-> [String: Any]? {
        if let group = group {
            return [
                "guid" : group.guid ,
                "name" : group.name ?? "",
                "type" : group.groupType.rawValue,
                "password" : group.password ?? "",
                "icon" : group.icon ?? "",
                "description" : group.description ,
                "owner" : group.owner ?? "",
                "metadata" : toJson(dictionary: group.metadata) as Any,
                "createdAt" : group.createdAt ,
                "updatedAt" : group.updatedAt,
                "hasJoined" : group.hasJoined,
                "joinedAt" : group.joinedAt,
                "scope" : group.scope.rawValue,
                "membersCount" : group.membersCount,
                "tags" : group.tags
            ]
        } else {
            return nil
        }
    }
    
    private func toJson(dictionary: [String: Any]?)-> String? {
        if let dictionary = dictionary {
            if let jsonData = (try? JSONSerialization.data(withJSONObject: dictionary , options: [])){
                let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)
                return jsonString
            } else {
                return nil
            }
        }else {
            return nil
        }
        
    }
    
    private func getAttachmentMap(attachment: Attachment?) -> [String: Any]? {
        if let attachment = attachment {
            return [
                "fileName" : attachment.fileName,
                "fileExtension" : attachment.fileExtension,
                "fileSize" : Int(attachment.fileSize) ?? 0,
                "fileMimeType" : attachment.fileMimeType as Any,
                "fileUrl" : attachment.fileUrl as Any,
            ]
        } else {
            return nil
        }
    }
}
