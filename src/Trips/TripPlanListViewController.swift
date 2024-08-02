//
//  TripPlanListViewController.swift
//  Tripezza
//
//  Created by Chloe Ang on 25/04/2023.
//
//  This page used to create itinerary.The user can create up to 10 itinerary.
//  The data here will be save in the core data.

import UIKit
import CoreData
class TripPlanListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, TripDatabaseListener{
    
    @IBOutlet weak var tableView: UITableView!
    
    let CELL_TRIP = "tripCell"
    let CELL_INFO = "infoCell"
    let SECTION_INFO = 1
    let SECTION_TRIP = 0
    
    var tripPlans: [Trip] = []
    var currentTrip: Trip?
    
    var listenerType: ListenerType = .trip
    weak var TripDatabaseController: TripDatabaseProtocol?
    var selectedTrip: Trip?
    var notification = NotificationTableTableViewController()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as?AppDelegate
        TripDatabaseController = appDelegate?.tripDatabaseController
        tableView.dataSource = self
        tableView.delegate = self
        
        // Make tableView edges rounded
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TripDatabaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TripDatabaseController?.removeListener(listener: self)
    }
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        
    }
    
    
    // MARK: - IBActions
    
    // this function is to add an itinerary
    @IBAction func addItineraryButton(_ sender: Any) {
        let alertController = UIAlertController(title: "Add a Trip and Date", message: nil, preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField{ (textField : UITextField!) -> Void in
            textField.placeholder = "Add a Trip"
        }
        alertController.addTextField { (textField2 : UITextField!) -> Void in
            textField2.placeholder = "yyyy-MM-dd"
        }
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: {
            _ in
            let tripText = alertController.textFields![0].text, dateText = alertController.textFields![1].text
            if self.tripPlans.count < 10 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let dateText = dateFormatter.date(from: dateText!)
                else {
                    print("Error: Invalid date format")
                    return
                }
                
                let _ = self.TripDatabaseController?.addTrip(name: tripText!, date: dateText)
                
            }
            else {
                self.displayMessage(title: "Error", message: "Trip is full")
            }
        })
        let cancelAction = UIAlertAction (title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    
    func onDestinationChange(change: DatabaseChange, destination: [Destination]) {
        //nothing
    }
    
    // UITableView is updated with changes received from a database and reloaded to show the updated trip plans
    func onTripChange(change: DatabaseChange, trip: [Trip]) {
        self.tripPlans = trip
        tableView.reloadData()
    }
    
    func onItineraryChange(change: DatabaseChange, itinerary: [Destination]) {
        //nothing
    }
    
    // this function shows error message with title and message
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
   
    // MARK: - UITableViewSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return tripPlans.count
        }else{
            return 1
        }
    }
    
    // this function constructs and populates the trip plan data into a UITableView.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_TRIP{
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_TRIP, for: indexPath)
            var content = cell.defaultContentConfiguration()
            let tripPlan = tripPlans[indexPath.row]
            content.text = tripPlan.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" // Set the desired date format
            if let date = tripPlan.date {
                let dateString = dateFormatter.string(from: date) // Convert Date to String
                content.secondaryText = dateString
            } else {
                content.secondaryText = nil // Handle the case when tripPlan.date is nil
            }
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell
        }else{
            let infocell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            var content = infocell.defaultContentConfiguration()
            if tripPlans.isEmpty{
                content.text = "Let's start to plan a trip. Tap + to add some"
            }else{
                content.text = "\(tripPlans.count) Trips in Planning"
            }
            
            infocell.contentConfiguration = content
            
            return infocell
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
        
    }
    
    func tableView(_ tableView: UITableView,commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete && indexPath.section == SECTION_TRIP{
            let trip = tripPlans[indexPath.row]
            self.TripDatabaseController?.deleteTrip(trip: trip)
      
            
        }
        
    }
    
    
    // MARK: - Navigation
    
    // a segue with the identifier "showItinerarySegue" triggers this code
    // the TripDatabaseController and destination ItineraryTableViewController are modified to set the selected trip as the current trip by retrieving it from the tripPlans array
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItinerarySegue" {
            let indexPath = tableView.indexPathForSelectedRow
            let selectedTrip = tripPlans[indexPath!.row]
            let itineraryDetailVC = segue.destination as! ItineraryTableViewController
            TripDatabaseController?.currentTrip = selectedTrip
            itineraryDetailVC.currentTrip = selectedTrip
    
        }}}




