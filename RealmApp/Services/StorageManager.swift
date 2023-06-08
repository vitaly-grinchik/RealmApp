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
    
    // MARK: - Tasks
    func add(_ task: Task) {
        write {
            realm.add(task)
        }
    }
    
    func save(taskWithTitle title: String, completion: (Task) -> Void) {
        write {
            let task = Task(value: [title])
            realm.add(task)
            completion(task)
        }
    }
    
    func delete(_ task: Task) {
        write {
            realm.delete(task.subTasks)
            realm.delete(task)
        }
    }
    
    func delete(_ subtask: SubTask, from task: Task) {
        write {
            guard let index = task.subTasks.firstIndex(of: subtask) else { return }
            let subTaskToDelete = task.subTasks[index]
            realm.delete(subTaskToDelete)
        }
    }
    
    func update(_ task: Task, withNewTitle title: String) {
        write {
            task.title = title
        }
    }

    func done(_ task: Task) {
        write {
            task.subTasks.setValue(true, forKey: "isComplete")
        }
    }

    // MARK: - Subtasks
    func add(subTaskWithTitle title: String, withNote note: String, to task: Task, completion: (SubTask) -> Void) {
        write {
            let subTask = SubTask(value: [title, note])
            task.subTasks.append(subTask)
            completion(subTask)
        }
    }
    
    // Realm state modifying (create/update/delete) transaction -> write method
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
