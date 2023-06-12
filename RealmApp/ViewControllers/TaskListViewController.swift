//
//  TaskListsViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

final class TaskListViewController: UITableViewController {

    // Свойство типа Results<Task>! автообновляется при каждом запросе БД
    private var tasks: Results<Task>!
    private let storageManager = StorageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        
        createTempData()
        tasks = storageManager.realm.objects(Task.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    private func createTempData() {
        if !UserDefaults.standard.bool(forKey: "done") {
            DataManager.shared.createTempData { [unowned self] in
                UserDefaults.standard.set(true, forKey: "done")
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        let task = tasks[indexPath.row]
        // Count current subtasks in the task
        let currentSubTaskQty = task.subTasks.filter("isComplete = false").count
        
        // Cell config
        var content = cell.defaultContentConfiguration()
        cell.accessoryType = (currentSubTaskQty != 0) ? .none : .checkmark
        content.text = task.title
        content.secondaryText = (currentSubTaskQty != 0) ? currentSubTaskQty.formatted() : nil
        cell.contentConfiguration = content
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = tasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            storageManager.delete(task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(for: task) {
                // Выполнение замыкания ПОСЛЕ закрытия AlertController
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self] _, _, isDone in
            storageManager.done(task)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let subTasksVC = segue.destination as? SubTasksViewController else { return }
        let task = tasks[indexPath.row]
        subTasksVC.task = task
    }

}

// MARK: - TaskList ALert
extension TaskListViewController {
    private func showAlert(for task: Task? = nil, completion: (() -> Void)? = nil) {
        let taskAlertController = TaskAlertControllerFactory(
            userAction: task != nil ? .editTask : .newTask,
            taskTitle: task?.title
        )
        
        let alert = taskAlertController.createAlert { [weak self] newTitle in
            // в замыкании предается String из поля алерта по нажатии Save
            if let task, let completion {
                self?.storageManager.save(task, withNewTitle: newTitle)
                // Выполнение замыкания ПОСЛЕ закрытия AlertController
                completion()
                return
            }
            self?.saveTask(with: newTitle)
        }
        
        present(alert, animated: true)
    }
    
    private func saveTask(with title: String) {
        storageManager.save(taskWithTitle: title) { task in
            let index = IndexPath(row: tasks.count - 1, section: 0)
            tableView.insertRows(at: [index], with: .automatic)
        }
    }
}
