//
//  Hotel2+CoreDataProperties.swift
//  Tripezza
//
//  Created by Chloe Ang on 11/06/2023.
//
//

import Foundation
import CoreData


extension Hotel2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hotel2> {
        return NSFetchRequest<Hotel2>(entityName: "Hotel2")
    }

    @NSManaged public var name: String?
    @NSManaged public var businessStatus: String?
    @NSManaged public var rating: Double
    @NSManaged public var vicinity: String?

}

extension Hotel2 : Identifiable {

}
