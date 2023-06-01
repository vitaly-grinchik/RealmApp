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

    private var taskList: Results<TaskList>!
    private let storageManager = StorageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = editButtonItem
        taskList = storageManager.realm.objects(TaskList.self)
        createTempData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let taskList = taskList[indexPath.row]
        content.text = taskList.title
        content.secondaryText = taskList.subTasks.count.formatted()
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = taskList[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            storageManager.delete(taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self] _, _, isDone in
            storageManager.done(taskList)
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
        let taskList = taskList[indexPath.row]
        subTasksVC.subTaskList = taskList
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
}

// MARK: - AlertController
extension TaskListViewController {
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let listAlertFactory = TaskListAlertControllerFactory(
            userAction: taskList != nil ? .editList : .newList,
            listTitle: taskList?.title
        )
        
        let alert = listAlertFactory.createAlert { [weak self] newValue in
            if let taskList, let completion {
                self?.storageManager.edit(taskList, newTitle: newValue)
                completion()
                return
            }
            
            self?.save(taskListTitle: newValue)
        }
        
        present(alert, animated: true)
    }
    
    private func save(taskListTitle: String) {
        storageManager.save(taskListTitle) { taskTitle in
            let rowIndex = IndexPath(row: taskList.index(of: taskTitle) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}
