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

class TodoViewController: UIViewController, UITableViewDelegate,
                          UITableViewDataSource, TodoItemsDelegate,
                          UITextFieldDelegate {

    var showCompleted = true
    var isUpdatingTitle: IndexPath? = nil

    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var gesture: UITapGestureRecognizer!

    @IBAction func onShowCompleted(sender: UIButton) {
        showCompleted = !showCompleted
        updateTable(todoItems: todos())
    }

    @IBAction func onEditClicked(sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        updateTable(todoItems: todos())
    }

    @IBAction func handleTap(sender: AnyObject) {
        textField.resignFirstResponder()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    @IBAction func onAddItem(sender: UIButton?) {

        guard let title = textField.text else {
            return
        }

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        textField.text = nil

        if let index = isUpdatingTitle {
            TodoItemDataManager.sharedInstance.update(withTitle: title,
                                                          atIndexPath: index)
            isUpdatingTitle = nil

        } else {
            TodoItemDataManager.sharedInstance.add(withTitle: title)
        }
        textField.resignFirstResponder()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        gesture.cancelsTouchesInView = false
        TodoItemDataManager.sharedInstance.delegate = self
        TodoItemDataManager.sharedInstance.get()
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onEditClicked(sender:)))
        self.navigationItem.rightBarButtonItem = editButton
    }

    override func viewWillAppear(_ animated: Bool) {

        // In case child view controller adjusted orientation
        view.frame = UIScreen.main.bounds
        view.bounds = UIScreen.main.bounds

        ThemeManager.replaceGradient(inView: view)

        updateTable(todoItems: todos())

        textField.textColor = ThemeManager.currentTheme().fontColor
        textField.attributedPlaceholder =
            NSAttributedString(string:"What Needs To Be Done?",
                               attributes:[NSForegroundColorAttributeName:
                                UIColor(red: 189, green: 189, blue: 189, opacity: 0.5)])
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // Setup Table Section Headers

    func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 50
    }

    func tableView(_ tableView: UITableView,
                     viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return UITableViewCell()
        } else {
            let optionCell = (tableView
                .dequeueReusableCell(withIdentifier: "OptionCell") as? OptionCell)!

            optionCell.showButton.layer.cornerRadius = 10
            optionCell.label.text = showCompleted ? "Hide Completed" : "Show Completed"

            let containerView = UIView(frame: optionCell.frame)
            optionCell.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(optionCell)

            return containerView
        }
    }

    func tableView(_ tableView: UITableView,
                     heightForRowAt indexPath: IndexPath) -> CGFloat {

        return !showCompleted && todos()[indexPath.section][indexPath.row].completed ? 0 : 50

    }

    // Setup TableView and TableViewCells

    func numberOfSections(in tableView: UITableView) -> Int {
        return todos().count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos()[section].count
    }

    func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath) as UITableViewCell

        var textAttributes = [
                              NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16.0)!,
                              NSForegroundColorAttributeName: ThemeManager.currentTheme().fontColor
        ]

        cell.textLabel?.attributedText = NSAttributedString(
                                string: todos()[indexPath.section][indexPath.row].title,
                                attributes: textAttributes)

        if tableView.isEditing {
            cell.imageView?.image = nil

        } else {
            if todos()[indexPath.section][indexPath.row].completed {
                cell.imageView?.image = UIImage(named: "blue_checkmark")

                textAttributes[NSStrikethroughStyleAttributeName] = NSNumber(value:
                    NSUnderlineStyle.styleSingle.rawValue)

                cell.textLabel?.attributedText =
                    NSAttributedString(string: todos()[indexPath.section][indexPath.row].title,
                                       attributes: textAttributes)
            } else {
                cell.imageView?.image = UIImage(named: "clear_checkmark")
            }
        }

        return cell
    }

    // Setup Editing Styles

    func tableView(_ tableView: UITableView,
                     shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView,
                     editingStyleForRowAt indexPath: IndexPath)
        -> UITableViewCellEditingStyle {

            return tableView.isEditing ? .delete : .delete
    }

    // Handle Pull Out Edit Bar

    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let onDelete = { (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            TodoItemDataManager.sharedInstance.delete(itemAt: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        let editAction = UITableViewRowAction(style: .default,
                                              title: "Edit",
                                            handler: onTodoEditHandler)
        let deleteAction = UITableViewRowAction(style: .default,
                                                title: "Delete",
                                              handler: onDelete)

        editAction.backgroundColor = ThemeManager.accessoryColor

        return [deleteAction, editAction]
    }

    // Setup Movable Rows

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView,
                     moveRowAt sourceIndexPath: IndexPath,
                       to destinationIndexPath: IndexPath) {

        TodoItemDataManager.sharedInstance.move(itemAt: sourceIndexPath,
                                                    to: destinationIndexPath)
        updateTable(todoItems: todos())

    }

    func tableView(_ tableView: UITableView,
                     targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                     toProposedIndexPath proposedDestinationIndexPath: IndexPath)
        -> IndexPath {

            // Prevent moving rows to different sections
            if sourceIndexPath.section != proposedDestinationIndexPath.section {
                var row = 0
                if sourceIndexPath.section < proposedDestinationIndexPath.section {
                    row = tableView.numberOfRows(inSection: sourceIndexPath.section) - 1
                }
                return IndexPath(row: row, section: sourceIndexPath.section)
            }
            return proposedDestinationIndexPath
    }
    
    // Allows Trash and Completion Marking

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableView.isEditing {
            //TodoItemDataManager.sharedInstance.delete(itemAt: indexPath)
            //tableView.deleteRows(at: [indexPath], with: .fade)
            updateTable(todoItems: TodoItemDataManager.sharedInstance.allTodos)
        } else {
            TodoItemDataManager.sharedInstance.update(indexPath: indexPath)
            updateTable(todoItems: TodoItemDataManager.sharedInstance.allTodos)
        }
    }

    // Text Field Delegate Methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onAddItem(sender: nil)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = nil
        textField.attributedPlaceholder =
            NSAttributedString(string:"What Needs To Be Done?",
                               attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
    }

    func updateTable(todoItems: [[TodoItem]]) {
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
        }

    }

    func todos() -> [[TodoItem]] {
        return TodoItemDataManager.sharedInstance.allTodos
    }

    func onItemsAddedToList() {
        updateTable(todoItems: todos())
    }

    func onTodoEditHandler(action: UITableViewRowAction!, indexPath: IndexPath!) {
        textField.becomeFirstResponder()
        isUpdatingTitle = indexPath
        tableView.isEditing = false

        textField.text = todos()[indexPath.section][indexPath.row].title
        tableView.contentInset = UIEdgeInsets(top:  0,
                                              left: 0,
                                              bottom: view.frame.size.height - 88,
                                              right: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        view.layer.sublayers?.first?.frame = self.view.bounds
    }
}
