//
//  CoreDateController.swift
//  Tripezza
//
//  Created by Chloe Ang on 02/05/2023.
//
// This is the controller to handle all the methods with the core data.

import UIKit
import CoreData

class CoreDateController: NSObject,TripDatabaseProtocol,NSFetchedResultsControllerDelegate {


    var listeners = MulticastDelegate<TripDatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var currentTrip: Trip?
    var allDestinationFetchedResultsController: NSFetchedResultsController<Destination>?
    var allTripFetchedResultsController: NSFetchedResultsController<Trip>?
    
    var notification = NotificationTableTableViewController()

    
    override init(){
        persistentContainer = NSPersistentContainer(name: "TripModel")
        persistentContainer.loadPersistentStores{(description, error) in if
            let error = error {
            fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
    }
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to core data with error: \(error)")
            }
        }
    }
    
    func addListener(listener: TripDatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .trip || listener.listenerType == .all {
            listener.onTripChange(change: .update, trip: fetchAllTrip() )
        }
        
        if listener.listenerType == .destination || listener.listenerType == .all{
            listener.onDestinationChange(change: .update, destination:  fetchAllDestination())
        }

        
    }
    
    func removeListener(listener: TripDatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    func addTrip(name: String,date:Date) -> Trip {
        let trip = NSEntityDescription.insertNewObject(forEntityName: "Trip", into: persistentContainer.viewContext) as! Trip
        trip.name  = name
        trip.date = date
        cleanup()
        // schedule a notification
        notification.scheduleLocalNotification(tripName:name,tripDate:date)
        return trip
    }
    
    func deleteTrip(trip: Trip) {

        persistentContainer.viewContext.delete(trip)
        // remove notification
        notification.cancelLocalNotification(tripName:trip.name!,tripDate:trip.date!)
        cleanup()
    }
    
    func addDestination(destination: String, startDate:Date, endDate:Date,trip:Trip) -> Destination
    {
        let des = NSEntityDescription.insertNewObject(forEntityName: "Destination", into: persistentContainer.viewContext) as! Destination
        
        des.destination = destination
        des.startDate = startDate
        des.endDate = endDate
        
        trip.addToIteneraries(des)
        
        cleanup()
        return des
    }
    
    func deleteDestination (destination: Destination,trip:Trip){
        persistentContainer.viewContext.delete(destination)
        
        trip.removeFromIteneraries(destination)

        cleanup()
    }

    func fetchAllTrip() -> [Trip] {
        if allTripFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            
            allTripFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            allTripFetchedResultsController?.delegate = self
            do {
                try allTripFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        var trip = [Trip]()
        if allTripFetchedResultsController?.fetchedObjects != nil {
            trip = (allTripFetchedResultsController?.fetchedObjects)!
        }
        
        return trip
    }
    func fetchAllDestination() -> [Destination] {
        let fetchRequest: NSFetchRequest<Destination> = Destination.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "destination", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        let predicate = NSPredicate(format: "ANY trips.name == %@", currentTrip!.name!)
        
        print(currentTrip!.name!)
        fetchRequest.predicate = predicate

        
        allDestinationFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        allDestinationFetchedResultsController?.delegate = self
        
        do {
            try allDestinationFetchedResultsController?.performFetch()
            
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        if allDestinationFetchedResultsController == nil {
        // do something
        }
    
        var des = [Destination]()
        if allDestinationFetchedResultsController?.fetchedObjects != nil {
            des = (allDestinationFetchedResultsController?.fetchedObjects)!
        }
        return des
    }
    
//    func isNull() -> [Destination]{
//        // Check if current trip name has changed
//        let currentTripName = currentTrip?.name
//        guard let previousTripName = allDestinationFetchedResultsController?.fetchRequest.predicate?.value(forKey: "name") as? String else {
//            // Previous trip name is nil, so fetchAllDestination should be called
//
//            return fetchAllDestination()
//        }
//        if currentTripName != previousTripName {
//            // Current trip name is different, so fetchAllDestination should be called
//            return fetchAllDestination()
//        }
//    }

        


        

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allDestinationFetchedResultsController {
            listeners.invoke(){
                listener in if listener.listenerType == .destination {
                    listener.onDestinationChange(change: .update, destination: fetchAllDestination())
                }
            }
        }
        if controller == allTripFetchedResultsController {
            listeners.invoke(){
            listener in if listener.listenerType == .trip{
                    listener.onTripChange(change: .update, trip: fetchAllTrip())
                        }
                    }
                }
      
        }
    func createDefaultTrip() {
        let destinations = [
            ["destination": "Italy", "startDate": "2024-04-30", "endDate": "2024-05-10"],
            ["destination": "Spain", "startDate": "2024-06-01", "endDate": "2024-06-15"],
            ["destination": "France", "startDate": "2024-07-01", "endDate": "2024-07-10"]
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for destination in destinations {
            let destinationName = destination["destination"] ?? ""
            let startDateString = destination["startDate"] ?? ""
            let endDateString = destination["endDate"] ?? ""

            guard let startDate = dateFormatter.date(from: startDateString),
                  let endDate = dateFormatter.date(from: endDateString) else {
                print("Error: Invalid date format")
                continue
            }

//            addDestination(destination: destinationName, startDate: startDate, endDate: endDate)
        }
    }

    
    
    
 
    
    

}
