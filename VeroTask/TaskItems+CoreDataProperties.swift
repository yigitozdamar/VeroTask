//
//  TaskItems+CoreDataProperties.swift
//  
//
//  Created by Yigit Ozdamar on 24.03.2023.
//
//

import Foundation
import CoreData


extension TaskItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskItems> {
        return NSFetchRequest<TaskItems>(entityName: "TaskItems")
    }

    @NSManaged public var title: String?
    @NSManaged public var task: String?
    @NSManaged public var descriptions: String?
    @NSManaged public var color: String?

}
