package space.cogitare.cometchat

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.cometchat.pro.core.*
import com.cometchat.pro.exceptions.CometChatException
import com.cometchat.pro.models.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.io.File


/** CometchatPlugin */
class CometchatPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var messageStream: EventChannel

    //    private lateinit var receiptStream: EventChannel
    //    private lateinit var typingStream: EventChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cometchat")
        channel.setMethodCallHandler(this)

        messageStream = EventChannel(flutterPluginBinding.binaryMessenger, "cometchat_message_stream")
        messageStream.setStreamHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "init" -> initializeCometChat(call, result)
            "createUser" -> createUser(call, result)
            "loginWithApiKey" -> loginWithApiKey(call, result)
            "loginWithAuthToken" -> loginWithAuthToken(call, result)
            "logout" -> logout(result)
            "getLoggedInUser" -> getLoggedInUser(result)
            "sendMessage" -> sendMessage(call, result)
            "sendMediaMessage" -> sendMediaMessage(call, result)
//            "sendCustomMessage" -> sendCustomMessage(call, result)
            "fetchPreviousMessages" -> fetchPreviousMessages(call, result)
            "fetchNextConversations" -> fetchNextConversations(call, result)
//            "getConversationFromMessage" -> getConversationFromMessage(call, result)
            "deleteMessage" -> deleteMessage(call, result)
            "createGroup" -> createGroup(call, result)
            "joinGroup" -> joinGroup(call, result)
            "leaveGroup" -> leaveGroup(call, result)
            "deleteGroup" -> deleteGroup(call, result)
            "fetchNextGroupMembers" -> fetchNextGroupMembers(call, result)
            "fetchNextGroups" -> fetchNextGroups(call, result)
            "registerTokenForPushNotification" -> registerTokenForPushNotification(call, result)
            "getUnreadMessageCount" -> getUnreadMessageCount(result)
            "markAsRead" -> markAsRead(call, result)
            "callExtension" -> callExtension(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        addMessageListener(events)
    }

    override fun onCancel(arguments: Any?) {
        Log.e("onCancel", "event onCancel called")
    }

    // CometChat functions
    private fun initializeCometChat(call: MethodCall, result: Result) {
        val appID: String = call.argument("appId") ?: ""
        val region: String = call.argument("region") ?: "us"

        val appSetting = AppSettings.AppSettingsBuilder().setRegion(region).subscribePresenceForAllUsers().build()

        CometChat.init(context, appID, appSetting, object : CometChat.CallbackListener<String>() {
            override fun onSuccess(m: String?) {
                Log.d("initializeCometChat", "Initialization completed successfully")
                result.success(null)
            }

            override fun onError(e: CometChatException) {
                Log.d("initializeCometChat", "Initialization failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun createUser(call: MethodCall, result: Result) {
        val apiKey: String = call.argument("apiKey") ?: ""
        val user = User()
        user.uid = call.argument("uid")
        user.name = call.argument("name")
        user.avatar = call.argument("avatar")

        CometChat.createUser(user, apiKey, object : CometChat.CallbackListener<User>() {
            override fun onSuccess(user: User) {
                Log.d("createUser", user.toString())
                result.success(getUserMap(user))
            }

            override fun onError(e: CometChatException) {
                Log.e("createUser", e.message ?: "Messed up")
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun loginWithApiKey(call: MethodCall, result: Result) {
        val uid: String = call.argument("uid") ?: ""
        val apiKey: String = call.argument("apiKey") ?: ""

        CometChat.login(uid, apiKey, object : CometChat.CallbackListener<User>() {
            override fun onSuccess(user: User) {
                Log.d("login", "Login Successful : $user")
                result.success(getUserMap(user))
            }

            override fun onError(e: CometChatException) {
                Log.e("login", "Login failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun loginWithAuthToken(call: MethodCall, result: Result) {
        val authToken: String = call.argument("authToken") ?: ""

        CometChat.login(authToken, object : CometChat.CallbackListener<User>() {
            override fun onSuccess(user: User) {
                Log.d("login", "Login Successful : $user")
                result.success(getUserMap(user))
            }

            override fun onError(e: CometChatException) {
                Log.e("login", "Login failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun logout(result: Result) {
        CometChat.logout(object : CometChat.CallbackListener<String>() {
            override fun onSuccess(m: String?) {
                Log.d("logout", "Logout completed successfully$m")
                result.success(null)
            }

            override fun onError(e: CometChatException) {
                Log.e("logout", "Logout failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun getLoggedInUser(result: Result) {
        val user: User? = CometChat.getLoggedInUser()
        result.success(user?.let { getUserMap(it) })
    }

    private fun sendMessage(call: MethodCall, result: Result) {
        val receiverID: String = call.argument("receiverId") ?: ""
        val messageText: String = call.argument("messageText") ?: ""
        val receiverType: String = call.argument("receiverType") ?: ""
        val parentMessageId: Int = call.argument("parentMessageId") ?: -1

        val textMessage = TextMessage(receiverID, messageText, receiverType)

        if (parentMessageId > 0) textMessage.parentMessageId = parentMessageId

        Log.d("sendMessage", "parentMessageId - $parentMessageId")

        CometChat.sendMessage(textMessage, object : CometChat.CallbackListener<TextMessage>() {
            override fun onSuccess(message: TextMessage) {
                Log.d("sendMessage", "Message sent successfully: $message")
                result.success(getMessageMap(message))
            }

            override fun onError(e: CometChatException) {
                Log.e("sendMessage", "Message sending failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun getMessageMap(message: BaseMessage): HashMap<String, Any?> {
        val map: HashMap<String, Any?> = hashMapOf(
                "id" to message.id,
                "muid" to message.muid,
                "sender" to getUserMap(message.sender),
                "receiver" to when (message.receiver) {
                    is User -> getUserMap(message.receiver as User)
                    is Group -> getGroupMap(message.receiver as Group)
                    else -> null
                },
                "receiverUid" to message.receiverUid,
                "type" to message.type,
                "receiverType" to message.receiverType,
                "category" to message.category,
                "sentAt" to message.sentAt,
                "deliveredAt" to message.deliveredAt,
                "readAt" to message.readAt,
                "metadata" to message.metadata?.toString(),
                "readByMeAt" to message.readByMeAt,
                "deliveredToMeAt" to message.deliveredToMeAt,
                "deletedAt" to message.deletedAt,
                "editedAt" to message.editedAt,
                "deletedBy" to message.deletedBy,
                "editedBy" to message.editedBy,
                "updatedAt" to message.updatedAt,
                "conversationId" to message.conversationId,
                "parentMessageId" to message.parentMessageId,
                "replyCount" to message.replyCount
        )
        when (message) {
            is TextMessage -> map["text"] = message.text
            is MediaMessage -> map.putAll(hashMapOf(
                    "caption" to message.caption,
                    "attachment" to getAttachmentMap(message.attachment)
            ))
            is Action -> map.putAll(hashMapOf(
                    "message" to message.message,
                    "rawData" to message.rawData,
                    "action" to message.action,
                    "oldScope" to message.oldScope,
                    "newScope" to message.newScope
            ))
        }
        return map
    }

    private fun getAttachmentMap(attachment: Attachment?): HashMap<String, Any?>? {
        if(attachment == null) return null
        return hashMapOf(
                "fileName" to attachment.fileName,
                "fileExtension" to attachment.fileExtension,
                "fileSize" to attachment.fileSize,
                "fileMimeType" to attachment.fileMimeType,
                "fileUrl" to attachment.fileUrl
        )
    }

    private fun getConversationMap(conversation: Conversation): HashMap<String, Any?> {
        return hashMapOf(
                "conversationId" to conversation.conversationId,
                "conversationType" to conversation.conversationType,
                "conversationWith" to when (conversation.conversationWith) {
                    is User -> getUserMap(conversation.conversationWith as User)
                    is Group -> getGroupMap(conversation.conversationWith as Group)
                    else -> null
                },
                "lastMessage" to getMessageMap(conversation.lastMessage),
                "unreadMessageCount" to conversation.unreadMessageCount,
                "updatedAt" to conversation.updatedAt
        )
    }

    private fun getGroupMap(group: Group): HashMap<String, Any?> {

        val groupMap = group.toMap()
        return hashMapOf(
                "guid" to group.guid,
                "name" to group.name,
                "type" to groupMap["type"],
                "password" to group.password,
                "icon" to group.icon,
                "description" to group.description,
                "owner" to group.owner,
                "metadata" to group.metadata?.toString(),
                "createdAt" to group.createdAt,
                "updatedAt" to group.updatedAt,
                "hasJoined" to (groupMap["hasJoined"]?.toInt() == 1),
                "joinedAt" to group.joinedAt,
                "scope" to group.scope,
                "membersCount" to group.membersCount,
                "tags" to group.tags
        )
    }

    private fun getUserMap(user: User): HashMap<String, Any?> {
        return hashMapOf(
                "uid" to user.uid,
                "name" to user.name,
                "avatar" to user.avatar,
                "link" to user.link,
                "role" to user.role,
                "metadata" to user.metadata?.toString(),
                "status" to user.status,
                "statusMessage" to user.statusMessage,
                "lastActiveAt" to user.lastActiveAt,
                "tags" to user.tags
        )
    }

    private fun getGroupMemberMap(groupMember: GroupMember): HashMap<String, Any?> {
        val map: HashMap<String, Any?> = getUserMap(groupMember)
        map.putAll(hashMapOf(
                "scope" to groupMember.scope,
                "joinedAt" to groupMember.joinedAt
        ))
        return map
    }

    private fun sendMediaMessage(call: MethodCall, result: Result) {
        val receiverID: String = call.argument("receiverId") ?: ""
        val receiverType: String = call.argument("receiverType") ?: ""
        val messageType: String = call.argument("messageType") ?: ""
        val filePath: String = call.argument("filePath") ?: ""
        val caption: String = call.argument("caption") ?: ""
        val parentMessageId: Int = call.argument("parentMessageId") ?: -1

        val mediaMessage = MediaMessage(receiverID, File(filePath), messageType, receiverType)

        if (caption.isNotEmpty()) mediaMessage.caption = caption

        if (parentMessageId > 0) mediaMessage.parentMessageId = parentMessageId

        CometChat.sendMediaMessage(mediaMessage, object : CometChat.CallbackListener<MediaMessage>() {
            override fun onSuccess(message: MediaMessage) {
                Log.d("sendMediaMessage", "Media message sent successfully: $message")
                result.success(getMessageMap(message))
            }

            override fun onError(e: CometChatException) {
                Log.e("sendMediaMessage", "Message sending failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

//    private fun sendCustomMessage(call: MethodCall, result: Result) {
//        val UID="UID"
//        val customType="Location"
//        val customData=JSONObject()
//        val customMessage = CustomMessage(UID, CometChatConstants.RECEIVER_TYPE_USER,customType, customData)
//
//        CometChat.sendCustomMessage(customMessage, object :CometChat.CallbackListener<CustomMessage>() {
//            override fun onSuccess(customMessage: CustomMessage) {
//                Log.d(TAG, customMessage.toString())
//            }
//            override fun onError(e: CometChatException) {
//                Log.d(TAG, e.message)
//            }
//        })
//    }

    private fun addMessageListener(result: EventChannel.EventSink) {
        CometChat.addMessageListener("space.cogitare.cometchat", object : CometChat.MessageListener() {
            override fun onTextMessageReceived(message: TextMessage) {
                Log.d("receiveMessage", "Message received successfully: ${message.text} sender: ${message.sender?.uid} receiver: ${message.receiverUid}")
                result.success(getMessageMap(message))
            }

            override fun onMediaMessageReceived(message: MediaMessage) {
                message.caption
                Log.d("receiveMessage", "Message received successfully: ${message.attachment.fileUrl} sender: ${message.sender?.uid} receiver: ${message.receiverUid}")
                result.success(getMessageMap(message))
            }
//            override fun onCustomMessageReceived(message: CustomMessage?) {
//            }

        })
    }

    private fun fetchPreviousMessages(call: MethodCall, result: Result) {
        val limit: Int = call.argument("limit") ?: -1
        val uid: String = call.argument("uid") ?: ""
        val guid: String = call.argument("guid") ?: ""
        val searchTerm: String = call.argument("searchTerm") ?: ""
        val messageId: Int = call.argument("messageId") ?: -1
        var builder: MessagesRequest.MessagesRequestBuilder = MessagesRequest.MessagesRequestBuilder()

        if (limit > 0) builder = builder.setLimit(limit)

        if (uid.isNotEmpty()) {
            builder = builder.setUID(uid)
        } else if (guid.isNotEmpty()) {
            builder = builder.setGUID(guid)
        }

        if (searchTerm.isNotEmpty()) builder = builder.setSearchKeyword(searchTerm)

        if (messageId > 0) builder = builder.setMessageId(messageId)

        val messagesRequest: MessagesRequest = builder.build()

        messagesRequest.fetchPrevious(object : CometChat.CallbackListener<List<BaseMessage>>() {
            override fun onSuccess(messages: List<BaseMessage>) {
                Log.d("fetchPreviousMessages", "Fetch messages successful: ${messages.size}")
                val list = messages.map { e -> getMessageMap(e) }
                result.success(list)
            }

            override fun onError(e: CometChatException) {
                Log.d("fetchPreviousMessages", "Message fetching failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }


    private fun fetchNextConversations(call: MethodCall, result: Result) {
        val limit: Int = call.argument("limit") ?: -1
        val type: String? = call.argument("type")
        var builder: ConversationsRequest.ConversationsRequestBuilder = ConversationsRequest.ConversationsRequestBuilder()

        if (limit > 0) builder = builder.setLimit(limit)

        if (type != null) builder = builder.setConversationType(type)

        val conversationRequest: ConversationsRequest = builder.build()
        conversationRequest.fetchNext(object : CometChat.CallbackListener<List<Conversation>>() {
            override fun onSuccess(conversations: List<Conversation>) {
                Log.d("fetchNextConversations", "Fetch conversations successful: ${conversations.size}")
                val list = conversations.map { e -> getConversationMap(e) }
                result.success(list)
            }

            override fun onError(e: CometChatException) {
                Log.e("fetchNextConversations", "Failed to fetch conversations: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

//    private fun getConversationFromMessage(call: MethodCall, result: Result) {
//        var message: TextMessage = TextMessage.fromJson(call.argument("message"))
//        CometChatHelper.getConversationFromMessage()
//    }

    private fun deleteMessage(call: MethodCall, result: Result) {
        val messageId: Int = call.argument("messageId") ?: -1

        CometChat.deleteMessage(messageId, object : CometChat.CallbackListener<BaseMessage>() {
            override fun onSuccess(message: BaseMessage) {
                Log.d("deleteMessage", "deleteMessage onSuccess : " + message.deletedAt)
                result.success(null)
            }

            override fun onError(e: CometChatException) {
                Log.d("deleteMessage", "deleteMessage onError : " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun createGroup(call: MethodCall, result: Result) {
        val guid: String = call.argument("guid") ?: ""
        val groupName: String = call.argument("groupName") ?: "New group"
        val groupType: String = call.argument("groupType") ?: ""
        val password: String = call.argument("password") ?: ""

        val group = Group(guid, groupName, groupType, password)

        CometChat.createGroup(group, object : CometChat.CallbackListener<Group>() {
            override fun onSuccess(group: Group) {
                Log.d("createGroup", "Group created successfully: $group")
                result.success(getGroupMap(group))
            }

            override fun onError(e: CometChatException) {
                Log.d("createGroup", "Group creation failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun joinGroup(call: MethodCall, result: Result) {
        val guid: String = call.argument("guid") ?: ""
        val groupType: String = call.argument("groupType") ?: ""
        val password: String = call.argument("password") ?: ""

        CometChat.joinGroup(guid, groupType, password, object : CometChat.CallbackListener<Group>() {
            override fun onSuccess(group: Group) {
                Log.d("joinGroup", "Group joined successfully: $group")
                result.success(getGroupMap(group))
            }

            override fun onError(e: CometChatException) {
                Log.d("joinGroup", "Group creation failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun leaveGroup(call: MethodCall, result: Result) {
        val guid: String = call.argument("guid") ?: ""

        CometChat.leaveGroup(guid, object : CometChat.CallbackListener<String>() {
            override fun onSuccess(m: String) {
                Log.d("leaveGroup", "Group left successfully: $m")
                result.success(null)
            }

            override fun onError(e: CometChatException) {
                Log.d("leaveGroup", "Group leaving failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun deleteGroup(call: MethodCall, result: Result) {
        val guid: String = call.argument("guid") ?: ""

        CometChat.deleteGroup(guid, object : CometChat.CallbackListener<String>() {
            override fun onSuccess(m: String) {
                Log.d("deleteGroup", "Group deleted successfully: $m")
                result.success(null)
            }

            override fun onError(e: CometChatException) {
                Log.d("deleteGroup", "Group delete failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun fetchNextGroupMembers(call: MethodCall, result: Result) {
        val guid: String = call.argument("guid") ?: ""
        val limit: Int = call.argument("limit") ?: -1
        var builder: GroupMembersRequest.GroupMembersRequestBuilder = GroupMembersRequest.GroupMembersRequestBuilder(guid)

        if (limit > 0) builder = builder.setLimit(limit)

        val groupMembersRequest: GroupMembersRequest = builder.build()

        groupMembersRequest.fetchNext(object : CometChat.CallbackListener<List<GroupMember>>() {
            override fun onSuccess(members: List<GroupMember>) {
                Log.d("fetchNextGroupMembers", "Group Member list fetched successfully: " + members.size)
                val list = members.map { e -> getGroupMemberMap(e) }
                result.success(list)
            }

            override fun onError(e: CometChatException) {
                Log.d("fetchNextGroupMembers", "Group Member list fetching failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun fetchNextGroups(call: MethodCall, result: Result) {
        val limit: Int = call.argument("limit") ?: -1
        val searchTerm: String = call.argument("searchTerm") ?: ""
        var builder: GroupsRequest.GroupsRequestBuilder = GroupsRequest.GroupsRequestBuilder()

        if (limit > 0) builder = builder.setLimit(limit)
        if (searchTerm.isNotEmpty()) builder.setSearchKeyWord(searchTerm)

        val groupsRequest: GroupsRequest = builder.build()

        groupsRequest.fetchNext(object : CometChat.CallbackListener<List<Group>>() {
            override fun onSuccess(groups: List<Group>) {
                Log.d("fetchNextGroups", "Groups list fetched successfully: " + groups.size)
                val list = groups.map { e -> getGroupMap(e) }
                result.success(list)
            }

            override fun onError(e: CometChatException) {
                Log.d("fetchNextGroups", "Groups list fetching failed with exception: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun registerTokenForPushNotification(call: MethodCall, result: Result) {
        val token: String = call.argument("token") ?: ""
        CometChat.registerTokenForPushNotification(token, object : CometChat.CallbackListener<String?>() {
            override fun onSuccess(s: String?) {
                Log.e("onSuccessPN: ", s ?: "Done")
                result.success(null)
            }

            override fun onError(e: CometChatException) {
                Log.e("onErrorPN: ", "Token save failed: " + e.message)
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun getUnreadMessageCount(result: Result) {
        CometChat.getUnreadMessageCount(object : CometChat.CallbackListener<HashMap<String, HashMap<String, Int>>>() {
            override fun onSuccess(counts: HashMap<String, HashMap<String, Int>>?) {
                Log.d("getUnreadMessageCount", "onSuccess: $counts")
                result.success(counts)
            }

            override fun onError(e: CometChatException) {
                Log.d("getUnreadMessageCount", "onError: ${e.message}")
                result.error(e.code, e.message, e.details)
            }
        })
    }

    private fun markAsRead(call: MethodCall, result: Result) {
        val messageId: Int = call.argument("messageId") ?: -1
        val senderId: String = call.argument("senderId") ?: ""
        val receiverType: String = call.argument("receiverType") ?: ""
        CometChat.markAsRead(messageId, senderId, receiverType)
        result.success(null)
        Log.d("markAsRead", "Success: $messageId $senderId $receiverType")
    }

    private fun callExtension(call: MethodCall, result: Result) {
        val slug: String = call.argument("slug") ?: ""
        val requestType: String = call.argument("requestType") ?: ""
        val endPoint: String = call.argument("endPoint") ?: ""

        val body: JSONObject = JSONObject(call.argument("body") ?: emptyMap<String, Any>())

        Log.d("callExtension", body.toString())

        CometChat.callExtension(slug, requestType, endPoint, body, object : CometChat.CallbackListener<JSONObject>() {
            override fun onSuccess(response: JSONObject) {
                Log.d("callExtension", "onSuccess: ${response.toString()}")
                result.success(response.toString())
            }

            override fun onError(e: CometChatException) {
                Log.d("callExtension", "onError: ${e.message}")
                result.error(e.code, e.message, e.details)
            }
        })
    }
}
