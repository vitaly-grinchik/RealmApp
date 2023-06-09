//
//  StorageManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import RealmSwift

final class StorageManager {
    
    static let shared = StorageManager()
    
    let realm = try! Realm()
    
    private init() {}
    
    // MARK: - CRUD
    func save(_ tasks: [Task]) {
        write {
            realm.add(tasks)
        }
    }
    
    func save(taskWithTitle title: String, completion: (Task) -> Void) {
        write {
            let task = Task(value: [title])
            realm.add(task)
            completion(task)
        }
    }
    
    func save(_ task: Task, withNewTitle title: String) {
        write {
            task.title = title
        }
    }
    
    func save(subTaskWithTitle title: String,
              withNote note: String,
              toTask task: Task,
              completion: (SubTask) -> Void)
    {
        write {
            let subTask = SubTask(value: [title, note])
            task.subTasks.append(subTask)
            completion(subTask)
        }
    }
    
    func save(_ subTask: SubTask,
              withNewTitle title: String,
              withNewNote note: String)
    {
        write {
            subTask.title = title
            subTask.note = note
        }
    }
    
    func delete(_ task: Task) {
        write {
            realm.delete(task.subTasks)
            realm.delete(task)
        }
    }
    
    func delete(_ subtask: SubTask) {
        write {
            realm.delete(subtask)
        }
    }
    
    func completeTask(_ task: Task) {
        write {
            task.subTasks.setValue(true, forKey: "isComplete")
        }
    }
    
    func toggleStatus(ofSubtask subTask: SubTask) {
        write {
            subTask.isComplete.toggle()
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
