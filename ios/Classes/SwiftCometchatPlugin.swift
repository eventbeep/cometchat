import Flutter
import UIKit
import CometChatPro

public class SwiftCometchatPlugin: NSObject, FlutterPlugin {
    
    //Initialize over here in order to get callback from Cometchat
    var messagesRequest = MessagesRequest.MessageRequestBuilder().set(limit: 50).build(); // for messages obj
    
    var convRequest = ConversationRequest.ConversationRequestBuilder(limit: 20).setConversationType(conversationType: .user).build() //for conversation obj
    
    var groupInstance = Group(guid: "", name: "", groupType: .public, password: "");
    
    var groupMembersRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: "").set(limit: 50).build();
    
    var groupsRequest  = GroupsRequest.GroupsRequestBuilder(limit: 50).build();
    
    var mediaMessage = MediaMessage(receiverUid: "", fileurl:"", messageType: .image, receiverType: .user);
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cometchat", binaryMessenger: registrar.messenger())
        let instance = SwiftCometchatPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //    result("iOS " + UIDevice.current.systemVersion)
        
        DispatchQueue.main.async { [weak self] in
            print("Method is , ",call.method)
            switch call.method {
            case "init":
                self?.initializeCometChat(args: call.arguments as! [String: Any], result:result)
            case "createUser":
                self?.createUser(args: call.arguments as! [String: Any], result:result)
            case "loginWithApiKey":
                self?.loginWithApiKey(args: call.arguments as! [String: Any], result:result)
            case "loginWithAuthToken":
                self?.loginWithAuthToken(args: call.arguments as! [String: Any], result:result)
            case "logout":
                self?.logout(args: call.arguments as! [String: Any], result:result)
            case "getLoggedInUser":
                self?.getLoggedInUser(result:result)
            case "sendMessage":
                self?.sendMessage(args: call.arguments as! [String: Any], result:result)
            case "sendMediaMessage":
                self?.sendMediaMessage(args: call.arguments as! [String: Any], result:result)
            case "fetchPreviousMessages":
                self?.fetchPreviousMessages(args: call.arguments as! [String: Any], result:result)
            case "fetchNextConversations":
                self?.fetchNextConversations(args: call.arguments as! [String: Any], result:result)
            case "deleteMessage":
                self?.deleteMessage(args: call.arguments as! [String: Any], result:result)
            case "createGroup":
                self?.createGroup(args: call.arguments as! [String: Any], result:result)
            case "joinGroup":
                self?.joinGroup(args: call.arguments as! [String: Any], result:result)
            case "leaveGroup":
                self?.leaveGroup(args: call.arguments as! [String: Any], result:result)
            case "deleteGroup":
                self?.deleteGroup(args: call.arguments as! [String: Any], result:result)
            case "fetchNextGroupMembers":
                self?.fetchNextGroupMembers(args: call.arguments as! [String: Any], result:result)
            case "fetchNextGroups":
                self?.fetchNextGroups(args: call.arguments as! [String: Any], result:result)
            case "registerTokenForPushNotification":
                self?.registerTokenForPushNotification(args: call.arguments as! [String: Any], result:result)
            case "getUnreadMessageCount":
                self?.getUnreadMessageCount(args: call.arguments as! [String: Any], result:result)
            case "markAsRead":
                self?.markAsRead(args: call.arguments as! [String: Any], result:result)
            case "callExtension":
                self?.callExtension(args: call.arguments as! [String: Any], result:result)
            default:
                result(FlutterMethodNotImplemented)
            }
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
        let receiverID = args["receiverId"] as? String ?? ""
        let messageText = args["messageText"] as? String ?? ""
        let receiver = args["receiverType"] as? String ?? ""
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
    
    private func sendMediaMessage(args: [String: Any], result: @escaping FlutterResult){
        
        let receiverid = args["receiverId"] as? String ?? ""
        let receiverType = args["receiverType"] as? String ?? ""
        let messageType = args["messageType"] as? Int ?? 0
        
        let filePath = args["filePath"] as? String ?? ""
        let caption = args["caption"] as? String ?? ""
        let parentMessageId = args["parentMessageId"] as? Int ?? 0

        
        if (caption == ""){
            self.mediaMessage.caption = caption
        }
        
        if (parentMessageId > 0) {
            self.mediaMessage.parentMessageId = parentMessageId
        }

        self.mediaMessage = MediaMessage(receiverUid: receiverid, fileurl:filePath, messageType: CometChat.MessageType(rawValue: messageType) ?? .image, receiverType: .user)
        CometChat.sendMediaMessage(message: self.mediaMessage, onSuccess: { (response) in

            result(self.getMessageMap(message: self.mediaMessage))
            
        }) { (error) in

            result(FlutterError(code: error?.errorCode ?? "",
                                message: error?.errorDescription, details: error?.debugDescription))
        }
        
    }
    
    private func fetchNextConversations(args: [String: Any], result: @escaping FlutterResult){
        
        let limit = args["limit"] as? Int ?? 50
        let typeValue = args["type"] as? String

//      If we want to fetch by Conversations
        var builder = ConversationRequest.ConversationRequestBuilder(limit: limit)

        if let typeValue = typeValue {
            if typeValue == "user" {
                builder = builder.setConversationType(conversationType: .user)
            } else if typeValue == "group" {
                builder = builder.setConversationType(conversationType: .group)
            }
        }

        self.convRequest = builder.build()
        self.convRequest.fetchNext(onSuccess: { (conversationList) in

            let list = conversationList.map { (e) -> [String : Any]? in
             return self.getConversationMap(conversation: e)
            }
            print("list count ",list.count)
            result(list)

        }) { (exception) in

          print("here exception \(String(describing: exception?.errorDescription))")
          result(FlutterError(code: exception?.errorCode ?? "",
                              message: exception?.errorDescription, details: exception?.debugDescription))
        }
        
//        If we Want to fetch by Messages
//        self.messagesRequest = MessagesRequest.MessageRequestBuilder().set(limit: limit).build();
//        self.messagesRequest.fetchNext(onSuccess: { (response) in
//            print("Message count is ,", response?.count ?? 0)
//
//            if let messages = response{
//                let conversationList = messages.map { (eachMsg) -> [String : Any]? in
//                    if let conversation = CometChat.getConversationFromMessage(eachMsg){
//                        return self.getConversationMap(conversation: conversation)
//                    }
//                    return [:]
//                }
//                result(conversationList)
//            }
//
//        }) { (error) in
//
//          print("Message receiving failed with error: " + error!.errorDescription);
//          print("here exception \(String(describing: error?.errorDescription))")
//          result(FlutterError(code: error?.errorCode ?? "",
//                                message: error?.errorDescription, details: error?.debugDescription))
//        }
    }
    
    private func fetchPreviousMessages(args: [String: Any], result: @escaping FlutterResult){

        let limit = args["limit"] as? Int ?? 50
        let uid = args["uid"] as? String ?? ""
        let guid = args["guid"] as? String ?? ""
        let searchTerm = args["searchTerm"] as? String ?? ""
        let messageId = args["messageId"] as? Int ?? 0
        
        var builder = MessagesRequest.MessageRequestBuilder()

        if (limit > 0) {
            builder = builder.set(limit: limit)
        }
        
        if (uid != "") {
            builder = builder.set(uid: uid)
        } else if (guid != "") {
            builder = builder.set(guid: guid)
        }
        if (searchTerm != ""){
            builder = builder.set(searchKeyword: searchTerm)
        }
        if (messageId > 0){
            builder = builder.set(messageID: messageId)
        }
        
        self.messagesRequest = builder.build()

        self.messagesRequest.fetchPrevious(onSuccess: { (response) in
            
            
                if let messages = response{
                    //print("types ,",messages.map{($0.mes)})
                    let conversationList = messages.map { (eachMsg) -> [String : Any]? in
                        return self.getMessageMap(message: eachMsg)
                        
                    }
                    result(conversationList)
                }
            
            
            

        }) { (error) in

          print("Message receiving failed with error: " + error!.errorDescription);
            result(FlutterError(code: error?.errorCode ?? "" ,
                                message: error?.errorDescription, details: error?.debugDescription))
        }
        
    }
    private func deleteMessage(args: [String: Any], result: @escaping FlutterResult){
        let msgID = args["messageId"] as? Int ?? 1
        
        CometChat.delete(messageId: msgID, onSuccess: { (baseMessage) in
           //print("message deleted successfully. \(baseMessage)")
            result(nil)
        }) { (error) in
           //print("delete message failed with error: \(error.errorDescription)")
            result(FlutterError(code: error.errorCode ,
                                message: error.errorDescription, details: error.debugDescription))
        }
        
    }
    private func createGroup(args: [String: Any], result: @escaping FlutterResult){
        
        let guid = args["guid"] as? String ?? ""
        let groupName = args["groupName"] as? String ?? ""
        let grpType = args["groupType"] as? String ?? ""
        let groupType : CometChat.groupType = grpType == "private" ? .private : grpType == "public" ? .private : .password
        let password = args["password"] as? String ?? nil //mandatory in case of password protected group type

        self.groupInstance = Group(guid: guid, name: groupName, groupType: groupType, password: password);

        CometChat.createGroup(group: self.groupInstance, onSuccess: { (group) in

          print("Group created successfully. " + group.stringValue())
           result(self.getGroupMap(group: group))

        }) { (error) in

          print("Group creation failed with error:" + error!.errorDescription);
            result(FlutterError(code: error?.errorCode ?? "" ,
                                message: error?.errorDescription, details: error?.debugDescription))
        }
        
    }
    private func joinGroup(args: [String: Any], result: @escaping FlutterResult){
        
        let guid = args["guid"] as? String ?? ""
        let grpType = args["groupType"] as? String ?? ""
        let groupType : CometChat.groupType = grpType == "private" ? .private : grpType == "public" ? .private : .password
        let password = args["password"] as? String ?? nil //mandatory in case of password protected group type
        
        CometChat.joinGroup(GUID: guid, groupType: groupType, password: password, onSuccess: { (group) in

          print("Group joined successfully. " + group.stringValue())
            result(self.getGroupMap(group: group))

        }) { (error) in

          print("Group joining failed with error:" + error!.errorDescription);
            result(FlutterError(code: error?.errorCode ?? "" ,
                                message: error?.errorDescription, details: error?.debugDescription))
        }
        
    }
    private func leaveGroup(args: [String: Any], result: @escaping FlutterResult){
        
        let guid = args["guid"] as? String ?? ""
        CometChat.leaveGroup(GUID: guid, onSuccess: { (response) in

            print("Left group successfully.")
            result(nil)
            
        }) { (error) in

          print("Group leaving failed with error:" + error!.errorDescription);
            result(FlutterError(code: error?.errorCode ?? "" ,
                                message: error?.errorDescription, details: error?.debugDescription))
        }
        
    }
    private func deleteGroup(args: [String: Any], result: @escaping FlutterResult){
        
        let guid = args["guid"] as? String ?? ""
        CometChat.deleteGroup(GUID: guid, onSuccess: { (response) in

          print("Group deleted successfully.")
          result(nil)
            
        }) { (error) in

          print("Group delete failed with error: " + error!.errorDescription);
            result(FlutterError(code: error?.errorCode ?? "" ,
                                message: error?.errorDescription, details: error?.debugDescription))
        }
        
    }
    private func fetchNextGroupMembers(args: [String: Any], result: @escaping FlutterResult){
        
        let limit = args["limit"] as? Int ?? 50
        let guid = args["guid"] as? String ?? ""

        self.groupMembersRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: guid).set(limit: limit).build();

        groupMembersRequest.fetchNext(onSuccess: { (groupMembers) in

            result(self.getGroupMemberMap(users: groupMembers))

        }) { (error) in

           print("Group Member list fetching failed with error:" + error!.errorDescription);
            result(FlutterError(code: error?.errorCode ?? "" ,
                                message: error?.errorDescription, details: error?.debugDescription))
        }
        
    }
    private func fetchNextGroups(args: [String: Any], result: @escaping FlutterResult){
        
        let limit = args["limit"] as? Int ?? 50

        self.groupsRequest  = GroupsRequest.GroupsRequestBuilder(limit: limit).build();
        groupsRequest.fetchNext(onSuccess: { (groups) in

            let list = groups.map { (eachGrp) -> [String : Any]? in
             return self.getGroupMap(group: eachGrp)
            }
            result(list)
            
        }) { (error) in

            print("Groups list fetching failed with error:" + error!.errorDescription);
            result(FlutterError(code: error?.errorCode ?? "" ,
                                message: error?.errorDescription, details: error?.debugDescription))
        }
        
    }
    
    private func getUnreadMessageCount(args: [String: Any], result: @escaping FlutterResult){
        
        CometChat.getUnreadMessageCount(onSuccess: { (response) in
                    
            print("Unread message count: \(response)")
            result(response)
                    
        }) { (error) in
                    
            print("Error in fetching unread count: \(error)")
            result(FlutterError(code: error?.errorCode ?? "" ,
                                message: error?.errorDescription, details: error?.debugDescription))
        }
        
    }
    private func markAsRead(args: [String: Any], result: @escaping FlutterResult){
        
        let messageId = args["messageId"] as? Int ?? 50
        let senderID = args["senderId"] as? String ?? ""

        CometChat.markAsRead(messageId: messageId, receiverId: senderID, receiverType: .user)
        
        
    }
    private func callExtension(args: [String: Any], result: @escaping FlutterResult){
        
        let slug = args["slug"] as? String ?? ""
        let requestType = args["requestType"] as? String ?? ""
        let postType : HTTPMethod = requestType == "post" ? .post : .get
        let endPoint = args["endPoint"] as? String ?? ""
        let body = args["body"] as? [String:Any] ?? [:]

        
        CometChat.callExtension(slug: slug,
                                type: postType,
                                endPoint: endPoint,
                                body: body) { (response) in
            
            result(response)
        } onError: { (error) in
            
            result(FlutterError(code: error?.errorCode ?? "" ,
                                message: error?.errorDescription, details: error?.debugDescription))
        }
    }
    
    private func registerTokenForPushNotification(args: [String: Any], result: @escaping FlutterResult){
        let token = args["token"] as? String ?? ""
        CometChat.registerTokenForPushNotification(token: token) { (response) in
            result(nil)
        } onError: { (error) in
            result(FlutterError(code: error?.errorCode ?? "" ,
                                message: error?.errorDescription, details: error?.debugDescription))
        }
    }
    
    
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
                "conversationId" : conversation.conversationId ?? "",
                "conversationType" : conversationType,
                "conversationWith" : conversationWith ?? [:],
                "updatedAt" : Int(conversation.updatedAt) ,
                "unreadMessageCount" : conversation.unreadMessageCount,
                "lastMessage":self.getMessageMap(message: conversation.lastMessage) ?? [:]
            ]
        } else {
            return nil
        }
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
    
    private func getGroupMemberMap(users: [GroupMember]) -> [[String:Any]]{
        var usersMap = [[String:Any]]()
        users.forEach { (user) in
            
                let status : String
                switch user.status {
                case .online:
                    status = "online"
                default:
                    status = "offline"
                }
                let eachUser = [
                    "uid" : user.uid ?? "",
                    "name" : user.name ?? "",
                    "avatar" : user.avatar ?? "",
                    "link" : user.link ?? "",
                    "role" : user.role ?? "",
                    "metadata" : toJson(dictionary: user.metadata) as Any,
                    "status" : status,
                    "statusMessage" : user.statusMessage ?? "",
                    "lastActiveAt" : Int(user.lastActiveAt) ?? 0,
                    "tags" : user.tags,
                    "scope" : user.scope.rawValue,
                    "joinedAt" : user.joinedAt
                ]
            usersMap.append(eachUser)
        }
        return usersMap
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

