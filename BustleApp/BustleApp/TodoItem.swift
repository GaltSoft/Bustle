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

import Foundation

struct TodoItem: Comparable {

    let id: String
    var title: String
    var completed: Bool
    var order: Int

    var jsonRepresentation: String {
        return "{\"title\":\"\(title)\",\"completed\":\"\(completed)\",\"rank\":\"\(order)\"}"
    }

}

func < (lhs: TodoItem, rhs: TodoItem) -> Bool {
    return lhs.order < rhs.order
}

func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
    return lhs.order == rhs.order
}
