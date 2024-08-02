//
//  Destination+CoreDataProperties.swift
//  Tripezza
//
//  Created by Chloe Ang on 11/06/2023.
//
//

import Foundation
import CoreData


extension Destination {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Destination> {
        return NSFetchRequest<Destination>(entityName: "Destination")
    }

    @NSManaged public var destination: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var trips: NSSet?

}

// MARK: Generated accessors for trips
extension Destination {

    @objc(addTripsObject:)
    @NSManaged public func addToTrips(_ value: Trip)

    @objc(removeTripsObject:)
    @NSManaged public func removeFromTrips(_ value: Trip)

    @objc(addTrips:)
    @NSManaged public func addToTrips(_ values: NSSet)

    @objc(removeTrips:)
    @NSManaged public func removeFromTrips(_ values: NSSet)

}

extension Destination : Identifiable {

}
