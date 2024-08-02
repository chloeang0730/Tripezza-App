//
//  DatabaseProtocol.swift
//  Tripezza
//
//  Created by Chloe Ang on 25/04/2023.
//

import Foundation
enum DatabaseChange{
    case add
    case remove
    case update
}

enum ListenerType {
    case trip
    case destination
    case itinerary
    case all
    
}


protocol DatabaseProtocol:AnyObject{
    
    var successfulSignUp: Bool {get set}
    func createNewUser(email: String, password: String, completion: @escaping () -> Void)
    func signInUser(email: String, password: String, completion: @escaping () -> Void)
    func signOutUser()


}
protocol DatabaseListener: AnyObject {
   //nothing
    
}
protocol TripDatabaseListener: AnyObject {
    var listenerType: ListenerType{get set}

    func onTripChange(change:DatabaseChange,trip:[Trip])
    func onDestinationChange(change:DatabaseChange,destination:[Destination])
}

protocol TripDatabaseProtocol: AnyObject {
    
    func cleanup()
    
    func addListener (listener: TripDatabaseListener)
    func removeListener (listener: TripDatabaseListener)
    
    func addDestination(destination: String, startDate:Date, endDate:Date,trip:Trip) -> Destination
    func deleteDestination (destination: Destination,trip:Trip)
    
    
    var currentTrip: Trip? {get set}
    
    func addTrip(name: String,date:Date) -> Trip
    func deleteTrip (trip: Trip)
  
}


