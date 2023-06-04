//
//  AlertController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 12.03.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import UIKit

protocol TaskListAlert {
    var listTitle: String? { get }
    func createAlert(completion: @escaping (String) -> Void) -> UIAlertController
}

protocol SubTaskAlert {
    var subTaskTitle: String? { get }
    var subTaskNote: String? { get }
    func createAlert(completion: @escaping (String, String) -> Void) -> UIAlertController
}

final class TaskListAlertControllerFactory: TaskListAlert {
    var listTitle: String?
    private let userAction: UserAction
    
    init(userAction: UserAction, listTitle: String?) {
        self.userAction = userAction
        self.listTitle = listTitle
    }
    
    func createAlert(completion: @escaping (String) -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: userAction.title,
            message: "Please set title for new task list",
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let listTitle = alertController.textFields?.first?.text else { return }
            guard !listTitle.isEmpty else { return }
            completion(listTitle)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { [weak self] textField in
            textField.placeholder = "New List"
            textField.text = self?.listTitle
        }
        
        return alertController
    }
}

// MARK: - TaskListUserAction
extension TaskListAlertControllerFactory {
    enum UserAction {
        case newList
        case editList
        
        var title: String {
            switch self {
            case .newList:
                return "New List"
            case .editList:
                return "Edit List"
            }
        }
    }
}

final class SubTaskAlertControllerFactory: SubTaskAlert {
    var subTaskTitle: String?
    var subTaskNote: String?
    
    private let userAction: UserAction
    
    init(userAction: UserAction, taskTitle: String?, taskNote: String?) {
        self.userAction = userAction
        self.subTaskTitle = taskTitle
        self.subTaskNote = taskNote
    }
    
    func createAlert(completion: @escaping (String, String) -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: userAction.title,
            message: "What do you want to do?",
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let taskTitle = alertController.textFields?.first?.text else { return }
            guard !taskTitle.isEmpty else { return }
            
            if let taskNote = alertController.textFields?.last?.text, !taskNote.isEmpty {
                completion(taskTitle, taskNote)
            } else {
                completion(taskTitle, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        alertController.addTextField { [weak self] textField in
            textField.placeholder = "New Task"
            textField.text = self?.subTaskTitle
        }
        
        alertController.addTextField { [weak self] textField in
            textField.placeholder = "Note"
            textField.text = self?.subTaskNote
        }
        
        return alertController
    }
}

// MARK: - TaskUserAction
extension SubTaskAlertControllerFactory {
    enum UserAction {
        case newTask
        case editTask
        
        var title: String {
            switch self {
            case .newTask:
                return "New Task"
            case .editTask:
                return "Edit Task"
            }
        }
    }
}
