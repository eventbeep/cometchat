import Flutter
import UIKit
import CometChatPro

public class SwiftCometchatPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cometchat", binaryMessenger: registrar.messenger())
        let instance = SwiftCometchatPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //    result("iOS " + UIDevice.current.systemVersion)
        switch call.method {
        case "init":
            initializeCometChat(args: call.arguments as! [String: Any], result:result)
        case "createUser":
            createUser(args: call.arguments as! [String: Any], result:result)
        case "loginWithApiKey":
            loginWithApiKey(args: call.arguments as! [String: Any], result:result)
        case "loginWithAuthToken":
            loginWithAuthToken(args: call.arguments as! [String: Any], result:result)
        case "logout":
            logout(args: call.arguments as! [String: Any], result:result)
        case "getLoggedInUser":
            getLoggedInUser(result:result)
        case "sendMessage":
            sendMessage(args: call.arguments as! [String: Any], result:result)
        case "sendMediaMessage":
            sendMediaMessage(args: call.arguments as! [String: Any], result:result)
        case "fetchPreviousMessages":
            fetchPreviousMessages(args: call.arguments as! [String: Any], result:result)
        case "fetchNextConversations":
            fetchNextConversations(args: call.arguments as! [String: Any], result:result)
        case "deleteMessage":
            deleteMessage(args: call.arguments as! [String: Any], result:result)
        case "createGroup":
            createGroup(args: call.arguments as! [String: Any], result:result)
        case "joinGroup":
            joinGroup(args: call.arguments as! [String: Any], result:result)
        case "leaveGroup":
            leaveGroup(args: call.arguments as! [String: Any], result:result)
        case "deleteGroup":
            deleteGroup(args: call.arguments as! [String: Any], result:result)
        case "fetchNextGroupMembers":
            fetchNextGroupMembers(args: call.arguments as! [String: Any], result:result)
        case "fetchNextGroups":
            fetchNextGroups(args: call.arguments as! [String: Any], result:result)
        case "registerTokenForPushNotification":
            registerTokenForPushNotification(args: call.arguments as! [String: Any], result:result)
        case "getUnreadMessageCount":
            getUnreadMessageCount(args: call.arguments as! [String: Any], result:result)
        case "markAsRead":
            markAsRead(args: call.arguments as! [String: Any], result:result)
        case "callExtension":
            callExtension(args: call.arguments as! [String: Any], result:result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initializeCometChat(args: [String: Any], result: @escaping FlutterResult){
        let appId = args["appId"] as! String
        let region = args["region"] as! String
        let mySettings = AppSettings.AppSettingsBuilder().subscribePresenceForAllUsers().setRegion(region: region).build()
        CometChat.init(appId: appId ,appSettings: mySettings,onSuccess: { (isSuccess) in
            print("CometChat Pro SDK intialise successfully.")
            result(Bool(isSuccess))
        }) { (error) in
            print("CometChat Pro SDK failed intialise with error: \(error.errorDescription)")
            result(FlutterError(code: error.errorCode,
                                message: error.errorDescription, details: error.debugDescription))
        }
    }
    
    private func createUser(args: [String: Any], result: @escaping FlutterResult){
        let apiKey = args["apiKey"] as! String
        let uid = args["uid"] as! String
        let name = args["name"] as! String
        let avatar = args["avatar"] as! String?
        
        let newUser : User = User(uid: uid, name: name)
        newUser.avatar = avatar
        CometChat.createUser(user: newUser, apiKey: apiKey, onSuccess: { (user) in
            print("User created successfully. \(user.stringValue())")
            result(self.getUserMap(user: user))
        }) { (error) in
            print("The error is \(String(describing: error?.description))")
            result(FlutterError(code: error?.errorCode ?? "",
                                message: error?.errorDescription, details: error?.debugDescription))
        }
    }
    
    private func loginWithApiKey(args: [String: Any], result: @escaping FlutterResult){
        let uid = args["uid"] as! String
        let apiKey = args["apiKey"] as! String
        
        CometChat.login(UID: uid, apiKey: apiKey) { (user) in
            print("User logged in successfully. \(user.stringValue())")
            result(self.getUserMap(user: user))
        } onError: { (error) in
            print("The error is \(String(describing: error.description))")
            result(FlutterError(code: error.errorCode,
                                message: error.errorDescription, details: error.debugDescription))
        }
    }
    
    private func loginWithAuthToken(args: [String: Any], result: @escaping FlutterResult){
        let authToken = args["authToken"] as! String
        
        CometChat.login(authToken: authToken) { (user) in
            print("User logged in successfully. \(user.stringValue())")
            result(self.getUserMap(user: user))
        } onError: { (error) in
            print("The error is \(String(describing: error.description))")
            result(FlutterError(code: error.errorCode,
                                message: error.errorDescription, details: error.debugDescription))
        }
    }
    
    private func logout(args: [String: Any], result: @escaping FlutterResult){
        CometChat.logout { (message) in
            result(String(message))
        } onError: { (error) in
            result(FlutterError(code: error.errorCode,
                                message: error.errorDescription, details: error.debugDescription))
        }
    }
    
    private func getLoggedInUser(result: @escaping FlutterResult){
        let user = CometChat.getLoggedInUser()
        print("Current User. \(user?.stringValue() ?? "Null")")
        result(getUserMap(user: user))
    }
    
    private func sendMessage(args: [String: Any], result: @escaping FlutterResult){
        let receiverID = args["receiverId"] as! String
        let messageText = args["messageText"] as! String
        let receiver = args["receiverType"] as! String
        _ = args["parentMessageId"] as? Int?
        
        print(messageText)
        
        let receiverType : CometChat.ReceiverType
        switch receiver {
        case "user":
            receiverType =  CometChat.ReceiverType.user
        default:
            receiverType =   CometChat.ReceiverType.group
        }
        
        let textMessage = TextMessage(receiverUid: receiverID , text: messageText, receiverType: receiverType)
        // TODO
        //        if parentMessageId != nil {
        //            textMessage.parentMessageId = parentMessageId
        //        }
        
        CometChat.sendTextMessage(message: textMessage, onSuccess: { (message) in
            print("TextMessage sent successfully. " + message.stringValue())
            result(self.getMessageMap(message: textMessage))
        }) { (error) in
            print("TextMessage sending failed with error: " + error!.errorDescription);
            result(FlutterError(code: error?.errorCode ?? "",
                                message: error?.errorDescription, details: error?.debugDescription))
        }
    }
    
    private func sendMediaMessage(args: [String: Any], result: @escaping FlutterResult){}
    
    private func fetchNextConversations(args: [String: Any], result: @escaping FlutterResult){
        let limit = args["limit"] as? Int ?? 50
        let typeValue = args["type"] as? String
        
        var builder = ConversationRequest.ConversationRequestBuilder(limit: limit)
        
        if let typeValue = typeValue {
            if typeValue == "user" {
                builder = builder.setConversationType(conversationType: .user)
            } else if typeValue == "group" {
                builder = builder.setConversationType(conversationType: .group)
            }
        }
        
        let convRequest = builder.build()
        
        print("Test 1")
        
        convRequest.fetchNext { (conversations) in
//            print("success of convRequest \(conversations)")
            print("Test 2")
            let conversationList = conversations.map { (e) -> [String : Any]? in
             return self.getConversationMap(conversation: e)
            }
            print("Test 2")
            result(conversationList)
        } onError: { (error) in
            print("here exception \(String(describing: error?.errorDescription))")
            result(FlutterError(code: error?.errorCode ?? "",
                                message: error?.errorDescription, details: error?.debugDescription))
        }
    }
    
    private func fetchPreviousMessages(args: [String: Any], result: @escaping FlutterResult){}
    private func deleteMessage(args: [String: Any], result: @escaping FlutterResult){}
    private func createGroup(args: [String: Any], result: @escaping FlutterResult){}
    private func joinGroup(args: [String: Any], result: @escaping FlutterResult){}
    private func leaveGroup(args: [String: Any], result: @escaping FlutterResult){}
    private func deleteGroup(args: [String: Any], result: @escaping FlutterResult){}
    private func fetchNextGroupMembers(args: [String: Any], result: @escaping FlutterResult){}
    private func fetchNextGroups(args: [String: Any], result: @escaping FlutterResult){}
    private func registerTokenForPushNotification(args: [String: Any], result: @escaping FlutterResult){}
    private func getUnreadMessageCount(args: [String: Any], result: @escaping FlutterResult){}
    private func markAsRead(args: [String: Any], result: @escaping FlutterResult){}
    private func callExtension(args: [String: Any], result: @escaping FlutterResult){}
    
    private func getConversationMap(conversation: Conversation?) -> [String: Any]? {
        if let conversation = conversation {
            var conversationWith : [String : Any]?
            var conversationType : String
            switch conversation.conversationType {
            case .user:
                conversationType = "user"
                conversationWith = getUserMap(user: conversation.conversationWith as? User)
            default:
                conversationType = "group"
                conversationWith = getGroupMap(group: conversation.conversationWith as? Group)
            }
            return [
                "conversationId" : conversation.conversationId as Any,
                "conversationType" : conversationType,
                "conversationWith" : conversationWith as Any,
                "updatedAt" : conversation.updatedAt,
                "unreadMessageCount" : conversation.unreadMessageCount,
            ]
        } else {
            return nil
        }
    }
    
    private func getMessageMap(message: BaseMessage?) -> [String: Any]? {
        print(message as Any)
        if let message = message {
            
            print(message.messageType)
            
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
            
            var type : String
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
            
            var category : String
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
                    "action" : action.action as Any,
                    "oldScope" : action.oldScope,
                    "newScope" : action.newScope,
                ]
                map.forEach { (key, value) in messageMap[key] = value }
            }
            
            return messageMap;
            
        } else {
            return nil
        }
    }
    
    private func getAttachmentMap(attachment: Attachment?) -> [String: Any]? {
        if let attachment = attachment {
            return [
                "fileName" : attachment.fileName,
                "fileExtension" : attachment.fileExtension,
                "fileSize" : attachment.fileSize,
                "fileMimeType" : attachment.fileMimeType as Any,
                "fileUrl" : attachment.fileUrl as Any,
            ]
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
                "uid" : user.uid as Any,
                "name" : user.name as Any,
                "avatar" : user.avatar as Any,
                "link" : user.link as Any,
                "role" : user.role as Any,
                "metadata" : toJson(dictionary: user.metadata) as Any,
                "status" : status,
                "statusMessage" : user.statusMessage as Any,
                "lastActiveAt" : user.lastActiveAt as Any,
                "tags" : user.tags
            ]
        } else {
            return nil
        }
    }
    
    private func getGroupMap(group: Group?)-> [String: Any]? {
        if let group = group {
            return [
                "guid" : group.guid,
                "name" : group.name as Any,
                "type" : group.groupType,
                "password" : group.password as Any,
                "icon" : group.icon as Any,
                "description" : group.description,
                "owner" : group.owner as Any,
                "metadata" : toJson(dictionary: group.metadata) as Any,
                "createdAt" : group.createdAt as Any,
                "updatedAt" : group.updatedAt as Any,
                "hasJoined" : group.hasJoined,
                "joinedAt" : group.joinedAt,
                "scope" : group.scope,
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
}

