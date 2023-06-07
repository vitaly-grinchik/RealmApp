//
//  Task.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import RealmSwift
import Foundation

class Task: Object {
    @Persisted var title = ""
    @Persisted var date = Date()
    @Persisted var subTasks = List<SubTask>()
}

class SubTask: Object {
    @Persisted var title = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}
