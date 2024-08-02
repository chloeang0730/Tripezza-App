//
//  Trip+CoreDataProperties.swift
//  Tripezza
//
//  Created by Chloe Ang on 11/06/2023.
//
//

import Foundation
import CoreData


extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var date: Date?
    @NSManaged public var name: String?
    @NSManaged public var iteneraries: NSSet?

}

// MARK: Generated accessors for iteneraries
extension Trip {

    @objc(addItenerariesObject:)
    @NSManaged public func addToIteneraries(_ value: Destination)

    @objc(removeItenerariesObject:)
    @NSManaged public func removeFromIteneraries(_ value: Destination)

    @objc(addIteneraries:)
    @NSManaged public func addToIteneraries(_ values: NSSet)

    @objc(removeIteneraries:)
    @NSManaged public func removeFromIteneraries(_ values: NSSet)

}

extension Trip : Identifiable {

}
