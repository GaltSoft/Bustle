/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit
import Foundation

protocol TodoItemsDelegate {
    func onItemsAddedToList()
}

enum DataManagerError: Error {
    case cannotSerializeToJSON
    case dataNotFound
}

extension DataManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .cannotSerializeToJSON: return "Cannot serialize to JSON"
        case .dataNotFound: return "Data was not found"
        }
    }
}

class TodoItemDataManager {

    let router = Router()
    let config = BluemixConfiguration()

    var delegate: TodoItemsDelegate!
    var allTodos: [[TodoItem]] = [[], []]

    static let sharedInstance = TodoItemDataManager()

//    private override init() {
//        super.init()
//        get()
//    }

}

// MARK: Methods for storing, deleting, updating, and retrieving
extension TodoItemDataManager {

    // Store item in todolist
    func add(withTitle: String) {
        let json = self.json(withTitle: withTitle,
                             order: TodoItemDataManager.sharedInstance.allTodos[0].count + 1)

        router.onPost(url: getBaseRequestURL(), jsonString: json) {
            response, error in

            if error != nil {
                print(error?.localizedDescription ?? "Other error")
            } else {

                guard let data = response else {
                    print(DataManagerError.dataNotFound)
                    return
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: data,
                                                                  options: .mutableContainers)
                    self.allTodos[0].append(self.parseItem(item: json)!)
                    self.delegate?.onItemsAddedToList()

                } catch {
                    print(DataManagerError.cannotSerializeToJSON)
                }
            }
        }
    }

    func delete(itemAt: IndexPath) {

        let id = allTodos[itemAt.section][itemAt.row].id
        self.allTodos[itemAt.section].remove(at: itemAt.row)

        router.onDelete(url: "\(getBaseRequestURL())/api/todos/\(id)") {
            response, error in

            if error != nil { print(error?.localizedDescription ?? "Other error") }
        }
    }

    func update(item: TodoItem) {
        router.onPatch(url: "\(getBaseRequestURL())/api/todos/\(item.id)",
                       jsonString: item.jsonRepresentation) {
            response, error in

            if error != nil { print(error?.localizedDescription ?? "Other error") }
        }

    }

    func update(indexPath: IndexPath) {
        var item = allTodos[indexPath.section].remove(at: indexPath.row)

        item.completed = !item.completed

        item.completed ? insertInOrder(seq: &allTodos[1], newItem: item) :
            insertInOrder(seq: &allTodos[0], newItem: item)

        self.update(item: item)
    }

    func update(withTitle: String, atIndexPath: IndexPath) {
        var item = allTodos[atIndexPath.section].remove(at: atIndexPath.row)

        item.title = withTitle

        item.completed ? insertInOrder(seq: &allTodos[1], newItem: item) :
            insertInOrder(seq: &allTodos[0], newItem: item)

        self.update(item: item)
    }

    func get(withId: String) -> TodoItem? {

        var item: TodoItem? = nil

        router.onGet(url: "\(getBaseRequestURL())/api/todos/\(withId)") {
            response, error in

            if error != nil { print(error?.localizedDescription ?? "Other error") } else {

                guard let data = response else {
                    print(DataManagerError.dataNotFound)
                    return
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: data,
                                                                  options: .mutableContainers)
                    item = self.parseItem(item: json)

                    self.delegate?.onItemsAddedToList()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }

        return item

    }

    // check connectivity to the server
    func hasConnection( oncompletion: @escaping (Bool) -> Void) {
        router.onGet(url: getBaseRequestURL()) {
            response, error in
            
            if error != nil {
                oncompletion(false)
            } else {
                oncompletion(true)
            }
            
        }
    }
    
    // Loads all TodoItems from designated base url

    func get() {

        router.onGet(url: getBaseRequestURL()) {
            response, error in

            if error != nil { print(error?.localizedDescription ?? "Other error") } else {

                guard let data = response else {
                    print(DataManagerError.dataNotFound)
                    return
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: data,
                                                                  options: .mutableContainers)
                    self.parseTodoList(json: json)
                    self.delegate?.onItemsAddedToList()

                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

// Methods for Parsing Functions
extension TodoItemDataManager {

    internal func parseTodoList(json: Any) {

        allTodos[0].removeAll()
        allTodos[1].removeAll()

        if let json = json as? [Any] {
            for item in json {

                guard let todo = parseItem(item: item) else {
                    continue
                }
                todo.completed ? insertInOrder(seq: &allTodos[1], newItem: todo) :
                                 insertInOrder(seq: &allTodos[0], newItem: todo)
            }
        }
    }

    internal func parseItem(item: Any) -> TodoItem? {

        if let item = item as? [String: Any] {

            let id        = item["id"] as? String
            let title     = item["title"] as? String
            let completed = item["completed"] as? Bool
            let order     = (item["order"] as? Int) ?? (item["rank"] as? Int)

            guard let uid = id,
                  let titleValue = title,
                  let completedValue = completed,
                  let orderValue = order else {

                    return nil
            }

            return TodoItem(id: uid, title: titleValue,
                            completed: completedValue, order: orderValue)
        }

        return nil
    }
}

// MARK: - Utility functions
extension TodoItemDataManager {

    func getBaseRequestURL() -> String {
        return config.isLocal ? config.localBaseRequestURL : config.remoteBaseRequestURL
    }

    func insertInOrder<T: Comparable>( seq: inout [T], newItem item: T) {
        let index = seq.reduce(0) { $1 < item ? $0 + 1 : $0 }
        seq.insert(item, at: index)
    }

    func move(itemAt: IndexPath, to: IndexPath) {

        var itemToMove = allTodos[itemAt.section][itemAt.row]

        itemToMove.order = allTodos[to.section][to.row].order

        allTodos[itemAt.section].remove(at: itemAt.row)
        allTodos[itemAt.section].insert(itemToMove, at: to.row)

        self.update(item: itemToMove)
    }

    func json(withTitle: String, order: Int) -> String {
        return "{\"title\":\"\(withTitle)\",\"completed\":\"\(false)\",\"rank\":\"\(order)\"}"
    }
}
