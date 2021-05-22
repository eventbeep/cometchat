import Flutter
import UIKit
//import CometChatPro

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
                initializeCometChat(call:call, result:result)
            case "createUser":
                createUser(call:call, result:result)
            case "loginWithApiKey":
                loginWithApiKey(call:call, result:result)
            case "loginWithAuthToken":
                loginWithAuthToken(call:call, result:result)
            case "logout":
                logout(call:call, result:result)
            case "getLoggedInUser":
                getLoggedInUser(call:call, result:result)
            case "sendMessage":
                sendMessage(call:call, result:result)
            case "sendMediaMessage":
                sendMediaMessage(call:call, result:result)
            case "fetchPreviousMessages":
                fetchPreviousMessages(call:call, result:result)
            case "fetchNextConversations":
                fetchNextConversations(call:call, result:result)
            case "deleteMessage":
                deleteMessage(call:call, result:result)
            case "createGroup":
                createGroup(call:call, result:result)
            case "joinGroup":
                joinGroup(call:call, result:result)
            case "leaveGroup":
                leaveGroup(call:call, result:result)
            case "deleteGroup":
                deleteGroup(call:call, result:result)
            case "fetchNextGroupMembers":
                fetchNextGroupMembers(call:call, result:result)
            case "fetchNextGroups":
                fetchNextGroups(call:call, result:result)
            case "registerTokenForPushNotification":
                registerTokenForPushNotification(call:call, result:result)
            case "getUnreadMessageCount":
                getUnreadMessageCount(call:call, result:result)
            case "markAsRead":
                markAsRead(call:call, result:result)
            case "callExtension":
                callExtension(call:call, result:result)
            default:
                result(FlutterMethodNotImplemented)    
        }
    }
    
    private func initializeCometChat(call: FlutterMethodCall, result: FlutterResult){}
    private func createUser(call: FlutterMethodCall, result: FlutterResult){}
    private func loginWithApiKey(call: FlutterMethodCall, result: FlutterResult){}
    private func loginWithAuthToken(call: FlutterMethodCall, result: FlutterResult){}
    private func logout(call: FlutterMethodCall, result: FlutterResult){}
    private func getLoggedInUser(call: FlutterMethodCall, result: FlutterResult){}
    private func sendMessage(call: FlutterMethodCall, result: FlutterResult){}
    private func sendMediaMessage(call: FlutterMethodCall, result: FlutterResult){}
    private func fetchPreviousMessages(call: FlutterMethodCall, result: FlutterResult){}
    private func fetchNextConversations(call: FlutterMethodCall, result: FlutterResult){}
    private func deleteMessage(call: FlutterMethodCall, result: FlutterResult){}
    private func createGroup(call: FlutterMethodCall, result: FlutterResult){}
    private func joinGroup(call: FlutterMethodCall, result: FlutterResult){}
    private func leaveGroup(call: FlutterMethodCall, result: FlutterResult){}
    private func deleteGroup(call: FlutterMethodCall, result: FlutterResult){}
    private func fetchNextGroupMembers(call: FlutterMethodCall, result: FlutterResult){}
    private func fetchNextGroups(call: FlutterMethodCall, result: FlutterResult){}
    private func registerTokenForPushNotification(call: FlutterMethodCall, result: FlutterResult){}
    private func getUnreadMessageCount(call: FlutterMethodCall, result: FlutterResult){}
    private func markAsRead(call: FlutterMethodCall, result: FlutterResult){}
    private func callExtension(call: FlutterMethodCall, result: FlutterResult){}
}

