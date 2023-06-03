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
    
    var taskList: TaskList!
    
    private var currentSubTasks: Results<SubTask>!
    private var completedSubTasks: Results<SubTask>!
    private let storageManager = StorageManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.title
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        currentSubTasks = taskList.subTasks.filter("isComplete = false")
        completedSubTasks = taskList.subTasks.filter("isComplete = true")
    }
        
    @objc private func addButtonPressed() {
        showAlert()
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
        let task = indexPath.section == 0 ? currentSubTasks[indexPath.row] : completedSubTasks[indexPath.row]
        content.text = task.title
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if taskList.subTasks.isEmpty {
                return "No tasks found"
            } else {
                return currentSubTasks.isEmpty ? nil : "Current tasks"
            }
        } else {
            return completedSubTasks.isEmpty ? nil : "Completed tasks"
        }
    }
    

}

extension SubTasksViewController {
    private func showAlert(with task: SubTask? = nil, completion: (() -> Void)? = nil) {
        let taskAlertFactory = TaskAlertControllerFactory(
            userAction: task != nil ? .editTask : .newTask,
            taskTitle: task?.title,
            taskNote: task?.note
        )
        let alert = taskAlertFactory.createAlert { [weak self] taskTitle, taskNote in
            if let task, let completion {
                // TODO: - edit task
            } else {
                self?.save(task: taskTitle, withNote: taskNote)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(task: String, withNote note: String) {
        storageManager.add(task, withTaskNote: note, to: taskList) { task in
            let rowIndex = IndexPath(row: currentSubTasks.index(of: task) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}
