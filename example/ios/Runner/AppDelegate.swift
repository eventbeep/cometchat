import UIKit
import Flutter
import CometChatPro

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,FlutterStreamHandler {
    
    var sink: FlutterEventSink?
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    guard let controller = window?.rootViewController as? FlutterViewController else {
         fatalError("rootViewController is not type FlutterViewController")
       }
    // iOS - AppDelegate.swift
    
//    let rootViewController : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channelName = "cometchat_message_stream"
    let methodChannel = FlutterEventChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    methodChannel.setStreamHandler(self)
    
    CometChat.messagedelegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.sink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.sink = nil
        return nil
    }
}


