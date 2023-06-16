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
        updateEditButtonState()
    }
     
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateEditButtonState()
        // Automaticaly open alert for newly created task
        if task.subTasks.isEmpty {
            showAlert()
        }
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
    }
    
    private func updateEditButtonState() {
        editButtonItem.isEnabled = !task.subTasks.isEmpty
    }
    
    // Section headers update
    private func checkTableSectionFilling() {
        if currentSubTasks.isEmpty {
            tableView.reloadSections([0], with: .automatic)
        } else if completedSubTasks.isEmpty {
            tableView.reloadSections([1], with: .automatic)
        }
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
        cell.configure(with: subTask)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        setHeader(forSection: section)
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let subTask = indexPath.section == 0 ? currentSubTasks[indexPath.row] : completedSubTasks[indexPath.row]
       
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            storageManager.delete(subTask)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            checkTableSectionFilling()
            updateEditButtonState()
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(for: subTask) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneUndoneAction = UIContextualAction(style: .normal,
                                                  title: subTask.isComplete ? "Undone" : "Done")
        { [unowned self] _, _, isDone in
            // Define a row at a section to move to
            storageManager.toggleStatus(ofSubtask: subTask)
            guard let newRow = indexPath.section == 0
                    ? completedSubTasks.index(of: subTask)
                    : currentSubTasks.index(of: subTask)
            else { return }
            
            let newIndexPath = IndexPath(row: newRow, section: subTask.isComplete ? 1 : 0)
                
            tableView.moveRow(at: indexPath, to: newIndexPath)
            tableView.cellForRow(at: newIndexPath)?.check(ifCompleted: subTask.isComplete)
            checkTableSectionFilling()
            
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneUndoneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneUndoneAction, editAction, deleteAction])
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
                                      withNewTitle: title,
                                      withNewNote: note
                )
                completion()
                return
            }
            saveSubTask(with: title, and: note)
            updateEditButtonState()
        }
        
        present(alert, animated: true)
    }
    
    private func saveSubTask(with title: String, and note: String) {
        storageManager.save(subTaskWithTitle: title, withNote: note, toTask: task) { subTask in
            let index = IndexPath(row: currentSubTasks.count - 1, section: 0)
            tableView.insertRows(at: [index], with: .automatic)
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

// MARK: - UITableViewCell
extension UITableViewCell {
    func check(ifCompleted done: Bool) {
        self.accessoryType = done ? .checkmark : .none
    }
    
    func configure(with subtask: SubTask) {
        var content = defaultContentConfiguration()
        content.text = subtask.title
        content.secondaryText = subtask.note
        contentConfiguration = content
        accessoryType = subtask.isComplete ? .checkmark : .none
    }
}
