//
//  AlertController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 12.03.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import UIKit

protocol TaskListAlert {
    var taskTitle: String? { get }
    func createAlert(completion: @escaping (String) -> Void) -> UIAlertController
}

protocol SubTaskAlert {
    var subTaskTitle: String? { get }
    var subTaskNote: String? { get }
    func createAlert(completion: @escaping (String, String) -> Void) -> UIAlertController
}

final class TaskAlertControllerFactory: TaskListAlert {
    var taskTitle: String?
    private let userAction: UserAction
    // Изначальное определение типа Алерта с соотвтетсвующим названием и сообщением
    init(userAction: UserAction, taskTitle: String?) {
        self.userAction = userAction
        self.taskTitle = taskTitle
    }
    // Создание полностью сконфигурированного AlertController для Task
    // По нажатии кнокпи Save передает строку из текстового поля
    func createAlert(completion: @escaping (String) -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: userAction.title,
            message: " Set title for a new task",
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let taskTitle = alertController.textFields?.first?.text else { return }
            guard !taskTitle.isEmpty else { return }
            completion(taskTitle)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { [weak self] textField in
            textField.placeholder = "New task"
            textField.text = self?.taskTitle
        }
        
        return alertController
    }
}

// MARK: - TaskListUserAction
extension TaskAlertControllerFactory {
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

final class SubTaskAlertControllerFactory: SubTaskAlert {
    var subTaskTitle: String?
    var subTaskNote: String?
    
    private let userAction: UserAction
    
    init(userAction: UserAction, subTaskTitle: String?, subTaskNote: String?) {
        self.userAction = userAction
        self.subTaskTitle = subTaskTitle
        self.subTaskNote = subTaskNote
    }
    
    func createAlert(completion: @escaping (String, String) -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: userAction.title,
            message: "Add subtask here",
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let subTaskTitle = alertController.textFields?.first?.text else { return }
            guard !subTaskTitle.isEmpty else { return }
            
            if let subTaskNote = alertController.textFields?.last?.text, !subTaskNote.isEmpty {
                completion(subTaskTitle, subTaskNote)
            } else {
                completion(subTaskTitle, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        alertController.addTextField { [weak self] textField in
            textField.placeholder = "New Subtask"
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
        case newSubTask
        case editSubTask
        
        var title: String {
            switch self {
            case .newSubTask:
                return "New Subtask"
            case .editSubTask:
                return "Edit Subtask"
            }
        }
    }
}
