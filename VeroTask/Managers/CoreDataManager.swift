//
//  CoreDataManager.swift
//  VeroTask
//
//  Created by Yigit Ozdamar on 24.03.2023.
//

import UIKit

class CoreDataManager {
    
    static var shared = CoreDataManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getAllTask(){
        do {
            let taks = try context.fetch(TaskCoreItems.fetchRequest())
        } catch  {
            //error
        }
    }
    
    func createTaskItems(title: String,description: String,color: String,task: String){
        let newItem = TaskCoreItems(context: context)
        newItem.title = title
    }
}
