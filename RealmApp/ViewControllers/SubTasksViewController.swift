//
//  SubTasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

final class SubTasksViewController: UITableViewController {
    
    var task: Task!
    
    private let storageManager = StorageManager.shared

    private var currentSubTasks: Results<SubTask>!
    private var completedSubTasks: Results<SubTask>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = task.title
        
        currentSubTasks = task.subTasks.filter("isComplete = false")
        completedSubTasks = task.subTasks.filter("isComplete = true")
        
        setupNavigationBar()
        updateEditButtonStatus()
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEditButtonStatus()
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        editButtonItem.isEnabled = task.subTasks.isEmpty ? false : true
    }
    
    private func updateEditButtonStatus() {
        editButtonItem.isEnabled = task.subTasks.isEmpty ? false : true
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
        let subTask = indexPath.section == 0 ? currentSubTasks[indexPath.row] : completedSubTasks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = subTask.title
        content.secondaryText = subTask.note
        cell.contentConfiguration = content
        cell.accessoryType = subTask.isComplete ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        setHeader(forSection: section)
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let subTask = indexPath.section == 0 ? currentSubTasks[indexPath.row] : completedSubTasks[indexPath.row]
       
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            storageManager.delete(subTask, fromTask: task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateEditButtonStatus()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(for: subTask) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self] _, _, isDone in
            storageManager.setStatus(ofSubtask: subTask, inTask: task, asCompleted: true)
            guard let newRow = completedSubTasks.index(of: subTask) else { return }
            let newIndexPath = IndexPath(row: newRow, section: 1)
            tableView.moveRow(at: indexPath, to: newIndexPath)
            tableView.cellForRow(at: newIndexPath)?.accessoryType = .checkmark

            isDone(true)
        }
        
        let undoneAction = UIContextualAction(style: .normal, title: "Undone") { [unowned self] _, _, isDone in
            storageManager.setStatus(ofSubtask: subTask, inTask: task, asCompleted: false)
            guard let newRow = currentSubTasks.index(of: subTask) else { return }
            let newIndexPath = IndexPath(row: newRow, section: 0)
            tableView.moveRow(at: indexPath, to: newIndexPath)
            tableView.cellForRow(at: newIndexPath)?.accessoryType = .none
            
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        undoneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        // Collecting all actions together
        let actionSet = [(indexPath.section == 0 ? doneAction : undoneAction), editAction, deleteAction]
        
        return UISwipeActionsConfiguration(actions: actionSet)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

// MARK: - SubTask Alert
extension SubTasksViewController {
    private func showAlert(for subTask: SubTask? = nil, completion: (() -> Void)? = nil) {
        let taskAlertFactory = SubTaskAlertControllerFactory(
            userAction: subTask != nil ? .editSubTask : .newSubTask,
            subTaskTitle: subTask?.title,
            subTaskNote: subTask?.note
        )
        
        let alert = taskAlertFactory.createAlert { [unowned self] title, note in
            if let subTask, let completion {
                storageManager.save(subTask,
                                      inTask: task,
                                      withNewTitle: title,
                                      withNewNote: note
                )
                completion()
                return
            }
            saveSubTask(with: title, and: note)
        }
        
        present(alert, animated: true)
    }
    
    private func saveSubTask(with title: String, and note: String) {
        storageManager.save(subTaskWithTitle: title, withNote: note, toTask: task) { subTask in
            let index = IndexPath(row: currentSubTasks.count - 1, section: 0)
            tableView.insertRows(at: [index], with: .automatic)
            updateEditButtonStatus()
        }
    }
    
}

// MARK: - Section Headers setting
extension SubTasksViewController {
    
    private func setHeader(forSection section: Int) -> String? {
        if section == 0 {
            if task.subTasks.isEmpty {
                return "No tasks found"
            } else {
                return currentSubTasks.isEmpty ? nil : "CURRENT TASKS"
            }
        } else {
            return completedSubTasks.isEmpty ? nil : "COMPLETED TASKS"
        }
    }
    
}
