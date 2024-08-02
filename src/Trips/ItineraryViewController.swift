//
//  ItineraryViewController.swift
//  Tripezza
//
//  Created by Chloe Ang on 01/05/2023.
//
//  This view controller will shows all the destinations that entered by the user.
//  Every itinerary shows their corresponding set of destinations.

import UIKit
import CoreData

class ItineraryTableViewController: UITableViewController, TripDatabaseListener{

    
  
    var itineraries: [Destination] = []
    let CELL_DES = "DestinationCell"
    var currentTrip: Trip?
    
    weak var TripDatabaseController: TripDatabaseProtocol?
    var listenerType = ListenerType.destination

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as?AppDelegate
        TripDatabaseController = appDelegate?.tripDatabaseController

        // Do any additional setup after loading the view.
        self.navigationItem.title = currentTrip?.name
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TripDatabaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TripDatabaseController?.removeListener(listener: self)
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itineraries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DES, for: indexPath)
        var content = cell.defaultContentConfiguration()
        let des = itineraries[indexPath.row]
        content.text = des.destination
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Set the desired date format
        if let date = des.startDate {
            let dateString = dateFormatter.string(from: date) // Convert Date to String
            content.secondaryText = dateString
        } else {
            content.secondaryText = nil // Handle the case when tripPlan.date is nil
        }
        cell.contentConfiguration = content
        
        return cell
    }
    override func tableView(_ tableView: UITableView,commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let destination = itineraries[indexPath.row]
            self.TripDatabaseController?.deleteDestination(destination: destination,trip:TripDatabaseController!.currentTrip!)
            
        }
    }
    // UITableView is updated with changes received from a database and reloaded to show the updated itinerary
    func onDestinationChange(change: DatabaseChange, destination: [Destination]) {
        itineraries = destination
        tableView.reloadData()

    }
    func onItineraryChange(change: DatabaseChange, itinerary: [Destination]) {
        //do nothing
   
        
    }
    func onTripChange(change: DatabaseChange, trip: [Trip]) {
        //do nothing
    }
    
    

}
