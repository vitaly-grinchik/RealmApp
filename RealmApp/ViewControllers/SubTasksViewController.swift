//
//  SubTasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

class SubTasksViewController: UITableViewController {
    
    var task: Task!
    
    private var currentSubTasks: Results<SubTask>!
    private var completedSubTasks: Results<SubTask>!
    
    private let storageManager = StorageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = task.title
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        updateDataSource()
    }
        
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    private func updateDataSource() {
        currentSubTasks = task.subTasks.filter("isComplete = false")
        completedSubTasks = task.subTasks.filter("isComplete = true")
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentSubTasks.count : completedSubTasks.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let subTask = indexPath.section == 0 ? currentSubTasks[indexPath.row] : completedSubTasks[indexPath.row]
        content.text = subTask.title
        content.secondaryText = subTask.note
        cell.contentConfiguration = content
        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if task.subTasks.isEmpty {
                return "No tasks found"
            } else {
                return currentSubTasks.isEmpty ? nil : "Current tasks"
            }
        } else {
            return completedSubTasks.isEmpty ? nil : "Completed tasks"
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let subTask = indexPath.section == 0 ? currentSubTasks[indexPath.row] : completedSubTasks[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            storageManager.delete(subTask, from: task)
//            task.subTasks.forEach { print($0.title) }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self] _, _, isDone in

            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    

}

// MARK: - SubTask Alert
extension SubTasksViewController {
    private func showAlert(with subTask: SubTask? = nil, completion: (() -> Void)? = nil) {
        let taskAlertFactory = SubTaskAlertControllerFactory(
            userAction: subTask != nil ? .editSubTask : .newSubTask,
            subTaskTitle: subTask?.title,
            subTaskNote: subTask?.note
        )
        
        let alert = taskAlertFactory.createAlert { [weak self] title, note in
            if let subTask, let completion {
//                self?.save(subTask: title, withNote: note)
            } else {
                
            }
        }
        
        present(alert, animated: true)
    }
    
//    private func save(subTask: String, withNote note: String) {
//        storageManager.add(subTaskWithTitle: subTask, withNote: note, to: task) { subTask in
//            let rowIndex = IndexPath(row: currentSubTasks.index(of: subTask) ?? 0, section: 0)
//            tableView.insertRows(at: [rowIndex], with: .automatic)
//        }
//
//    }
}
