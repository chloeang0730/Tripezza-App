//
//  NotificationTableTableViewController.swift
//  Tripezza
//
//  Created by Chloe Ang on 03/06/2023.
//
// This class create local notification.
// Beside setting local notification, I make a viiew controller for notifications.
// User is able to see the reminder for the trip in this view.

import UIKit
import UserNotifications
import CoreData

class NotificationTableTableViewController: UITableViewController ,NSFetchedResultsControllerDelegate{
    
    var notifications: [UNNotificationRequest] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // request for authorization from user
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                if granted {
                    print("Local notification permission granted")
                } else {
                    print("Local notification permission denied")
                }
            }
            
    }
    override func viewWillAppear(_ animated: Bool) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            // Store the fetched notifications in the array
            self?.notifications = requests
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let date = trigger.nextTriggerDate()

                }
            }
            
            // Reload the table view on the main queue
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    

    // this function handle the case when user interact with the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification response
        let notification = response.notification
        let content = notification.request.content
        tableView.reloadData()
        completionHandler()
    }
    
   
    // this function remove a notification with a unique identifier
    func cancelLocalNotification(tripName:String,tripDate:Date) {
        let identifier = "TripNotification_\(String(describing: tripName))" // Unique identifier for the notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("cancel notification")
    }
    
    // this function schedule a notification
    func scheduleLocalNotification(tripName:String,tripDate:Date) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Trip"
        content.body = "Your trip to \(String(describing: tripName)) is coming up!"
        content.sound = .default

        let calendar = Calendar.current
        let tripDate = tripDate
        
        
        let triggerDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: tripDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

        let identifier = "TripNotification_\(String(describing: tripName))" // Unique identifier for the notification
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local notification:", error.localizedDescription)
            } else {
                print("Local notification scheduled successfully for trip: \(tripName)")
            }
        }
    }


    




    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notifications.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
            let notificationRequest = notifications[indexPath.row]
            let notificationContent = notificationRequest.content
            var content = cell.defaultContentConfiguration()
            content.text = notificationContent.body
            cell.contentConfiguration = content
            
            return cell
    }
    

}
