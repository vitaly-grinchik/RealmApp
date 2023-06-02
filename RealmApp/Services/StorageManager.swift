//
//  StorageManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import RealmSwift

class StorageManager {
    
    static let shared = StorageManager()
    
    let realm = try! Realm()
    
    private init() {}
    
    // MARK: - Task List
    func add(_ taskLists: [TaskList]) {
        write {
            realm.add(taskLists)
        }
    }
    
    func save(_ taskListTitle: String, completion: (TaskList) -> Void) {
        write {
            let taskList = TaskList(value: [taskListTitle])
            realm.add(taskList)
            completion(taskList)
        }
    }
    
    func delete(_ taskList: TaskList) {
        write {
            realm.delete(taskList.subTasks)
            realm.delete(taskList)
        }
    }
    
    func edit(_ taskList: TaskList, newTitle: String) {
        write {
            taskList.title = newTitle
        }
    }

    func done(_ taskList: TaskList) {
        write {
            taskList.subTasks.setValue(true, forKey: "isComplete")
        }
    }

    // MARK: - Tasks
    func add(_ taskTitle: String, withTaskNote taskNote: String, to taskList: TaskList, completion: (SubTask) -> Void) {
        write {
            let task = SubTask(value: [taskTitle, taskNote])
            taskList.subTasks.append(task)
            completion(task)
        }
    }
    
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
