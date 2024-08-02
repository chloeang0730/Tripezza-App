//
//  AppDelegate.swift
//  Tripezza
//
//  Created by Chloe Ang on 25/04/2023.
//  Hi

import UIKit
import FirebaseCore


@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var databaseController: DatabaseProtocol?
    var tripDatabaseController: TripDatabaseProtocol?
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        databaseController = FirebaseController()
        tripDatabaseController = CoreDateController()
  
        UNUserNotificationCenter.current().delegate = self
        
        let acceptAction = UNNotificationAction(identifier: "accept", title: "Accept", options: .foreground)
        let declineAction = UNNotificationAction(identifier: "decline", title: "Decline", options: .destructive)
        let commentAction = UNTextInputNotificationAction(identifier: "comment", title: "Comment", options: .authenticationRequired, textInputButtonTitle: "Send", textInputPlaceholder: "Type a response")
        // Set up the category
        let appCategory = UNNotificationCategory(identifier: "TRIPEZZACATEGORY", actions: [acceptAction, declineAction, commentAction], intentIdentifiers: [], options: [])
            
        // Register the new category with the notification center
        UNUserNotificationCenter.current().setNotificationCategories([appCategory])
            
        // Other app initialization code
        return true
    }
    
    // Run code and handle how notifications are presented while app is running.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification received")
        completionHandler([.banner])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.notification.request.content.categoryIdentifier { case "TRIPEZZACATEGORY":
            switch response.actionIdentifier { case "decline":
                print("declined") case "accept":
                print("accepted") case "comment":
                // In this case we know that it is a user response instead
                let userResponse = response as! UNTextInputNotificationResponse
                print(userResponse.userText) default:
                break
            } default:
            break
        }
        completionHandler()
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //import FirebaseCore
//    /FirebaseApp.configure()/

}

