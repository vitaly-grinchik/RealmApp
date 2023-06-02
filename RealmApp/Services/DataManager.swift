//
//  DataManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    private let storageManager = StorageManager.shared
    
    private init() {}
    
    func createTempData(completion: @escaping () -> Void ) {
        let shoppingList = TaskList()
        shoppingList.title = "Shopping List"
        
        let moviesList = TaskList(
            value: [
                "Movies List",
                Date(),
                [
                    ["The best of the best", "Must have", Date(), true] as [Any],
                    ["Best film ever"]
                ]
            ] as [Any]
        )
        
        let milk = SubTask()
        milk.title = "Milk"
        milk.note = "2L"
        
        let bread = SubTask(value: ["Bread", "", Date(), true] as [Any])
        let apples = SubTask(value: ["title": "Apples", "note": "2Kg"])
        
        shoppingList.subTasks.append(milk)
        shoppingList.subTasks.insert(contentsOf: [bread, apples], at: 1)
        
        DispatchQueue.main.async { [unowned self] in
            storageManager.add([shoppingList, moviesList])
            completion()
        }
    }
}
