//
//  TaskCoreItems+CoreDataProperties.swift
//  VeroTask
//
//  Created by Yigit Ozdamar on 24.03.2023.
//
//

import Foundation
import CoreData


extension TaskCoreItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskCoreItems> {
        return NSFetchRequest<TaskCoreItems>(entityName: "TaskCoreItems")
    }

    @NSManaged public var title: String?
    @NSManaged public var task: String?
    @NSManaged public var descriptions: String?
    @NSManaged public var color: String?

}

extension TaskCoreItems : Identifiable {

}
