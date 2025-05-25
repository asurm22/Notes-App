//
//  Note2+CoreDataProperties.swift
//  Notes2
//
//  Created by alex surmava on 30.01.25.
//
//

import Foundation
import CoreData


extension Note2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note2> {
        return NSFetchRequest<Note2>(entityName: "Note2")
    }

    @NSManaged public var color: Int64
    @NSManaged public var favourite: Bool
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var locked: Bool
    @NSManaged public var password: Int64

}

extension Note2 : Identifiable {

}
