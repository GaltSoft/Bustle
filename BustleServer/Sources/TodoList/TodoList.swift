
import Foundation
import SQL
import Axis
import PostgreSQL
import HeliumLogger
import LoggerAPI

/**
 The PostgreSQL database should contain the following schema:

 CREATE TABLE todos
 (
	tid 		bigserial 		PRIMARY KEY,
 	user_id 	varchar(128)	NOT NULL,
	title		varchar(256)	NOT NULL,
	completed	boolean			NOT NULL,
	ordering	integer			NOT NULL
 );

*/
let COUNT = "count"
let TID = "tid"
let TITLE = "title"
let COMPLETED = "completed"
let ORDER = "ordering"


public final class TodoList: TodoListAPI {
    
    static let defaultPostgreHost = "localhost"
    static let defaultPostgrePort = Int32(5432)
    static let defaultDatabaseName = "todolist"
    static let defaultPostgreUsername = "travis"
    static let defaultPostgrePassword = ""
    var postgreConnection: PostgreSQL.Connection!

    var database: String = TodoList.defaultDatabaseName
    var defaultUsername = "default"

    public init(database: String = TodoList.defaultDatabaseName,
                host: String = TodoList.defaultPostgreHost,
                port: Int32 = TodoList.defaultPostgrePort,
                username: String = TodoList.defaultPostgreUsername, password: String = TodoList.defaultPostgrePassword) {

        do {
            let connectionString = URL(string: "postgres://\(username):\(password)@\(host):\(port)/\(database)")!
            postgreConnection = try PostgreSQL.Connection(info: .init(connectionString))

            // Open the server
            try postgreConnection.open()

            // Check the status
            guard postgreConnection.internalStatus == PostgreSQL.Connection.InternalStatus.OK else {
                throw TodoCollectionError.ConnectionRefused
            }
        } catch {
            print("(\(#function) at \(#line)) - Failed to connect to the server")
        }
    }

    public init(_ uri: String) {

        do {
            let connectionString = URL(string: uri)!
            postgreConnection = try PostgreSQL.Connection(info: .init(connectionString))

            // Open
            try postgreConnection.open()

            // Check the server status
            guard postgreConnection.internalStatus == PostgreSQL.Connection.InternalStatus.OK else {
                throw TodoCollectionError.ConnectionRefused
            }

        } catch {
            print("(\(#function) at \(#line)) - Failed to connect to the server")
        }
    }

    public func count(withUserID: String?, oncompletion: @escaping(Int?, Error?) -> Void) {

        let userID = withUserID ?? defaultUsername

        let query = "SELECT COUNT(*) FROM todos WHERE user_id='\(userID)';"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }

            guard let count = try Int(String(describing: result[0].data(COUNT))) else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }
            oncompletion(count, nil)

        } catch {
            oncompletion(nil, error)
        }
    }

    public func clear(withUserID: String?, oncompletion: @escaping(Error?) -> Void) {

        let userID = withUserID ?? defaultUsername
        let query = "DELETE FROM todos WHERE user_id='\(userID)';"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.CommandOK else {
                oncompletion(TodoCollectionError.ParseError)
                return
            }
            oncompletion(nil)

        } catch {
            oncompletion(error)
        }
    }

    public func clearAll(oncompletion: @escaping(Error?) -> Void) {

        let query = "TRUNCATE TABLE todos;"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.CommandOK else {
                oncompletion(TodoCollectionError.ParseError)
                return
            }
            oncompletion(nil)

        } catch {
            oncompletion(error)
        }
    }

    public func get(withUserID: String?, oncompletion: @escaping([TodoItem]?, Error?) -> Void) {

        let userID = withUserID ?? defaultUsername
        let query = "SELECT * FROM todos WHERE user_id='\(userID)';"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }
            var todoItems = [TodoItem]()

            for i in 0 ..< result.count {
                let tid = try String(describing: result[i].data(TID))
                let title = try String(describing: result[i].data(TITLE))
                let completed = try String(describing: result[i].data(COMPLETED)) == "t" ? true : false
                guard let order = try Int(String(describing: result[i].data(ORDER))) else {
                    oncompletion(nil, TodoCollectionError.ParseError)
                    return
                }

                todoItems.append(TodoItem(documentID: tid, userID: userID, rank: order, title: title, completed: completed))
            }

            oncompletion(todoItems, nil)

        } catch {
            oncompletion(nil, error)
        }
    }

    public func get(withUserID: String?, withDocumentID: String, oncompletion: @escaping(TodoItem?, Error?) -> Void ) {

        let userID = withUserID ?? defaultUsername
        let query = "SELECT * FROM todos WHERE user_id='\(userID)' AND tid='\(withDocumentID)';"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }
            let title = try String(describing: result[0].data(TITLE))
            let completed = try String(describing: result[0].data(COMPLETED)) == "t" ? true : false
            guard let order = try Int(String(describing: result[0].data(ORDER))) else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }
            let todoItem = TodoItem(documentID: withDocumentID, userID: userID, rank: order, title: title, completed: completed)
            oncompletion(todoItem, nil)

        } catch {
            oncompletion(nil, error)
        }
    }

    public func add(userID: String?, title: String, rank: Int, completed: Bool,
             oncompletion: @escaping(TodoItem?, Error?) -> Void ) {

        let userID = userID ?? defaultUsername
        let query = "INSERT INTO todos (user_id, title, completed, ordering) VALUES ('\(userID)', '\(title)', \(completed), \(rank)) RETURNING tid;"

        do {
            let result = try self.postgreConnection.execute(query)
            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }

            let docID = try (String(describing: result[0].data(TID)))
            let todoItem = TodoItem(documentID: docID, userID: userID, rank: rank, title: title, completed: completed)
            oncompletion(todoItem, nil)

        } catch {
            oncompletion(nil, error)
        }
    }

    public func update(documentID: String, userID: String?, title: String?, rank: Int?,
                completed: Bool?, oncompletion: @escaping(TodoItem?, Error?) -> Void ) {

        let userID = userID ?? defaultUsername

        var query = "UPDATE todos SET"
        var updateValues = [String]()

        if let title = title {
            updateValues.append(" title = '\(title)' ")
        }

        if let rank = rank {
            updateValues.append(" ordering = \(rank) ")
        }

        if let completed = completed {
            updateValues.append(" completed = \(completed) ")
        }

        let joiner = ","
        let joinedString = updateValues.joined(separator: joiner)
        query.append(joinedString)

        let condition = "WHERE tid='\(documentID)' AND user_id='\(userID)' RETURNING title, ordering, completed;"
        query.append(condition)

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }

            let title = try String(describing: result[0].data(TITLE))
            let completed = try String(describing: result[0].data(COMPLETED)) == "t" ? true : false
            guard let rank = try Int(String(describing: result[0].data(ORDER))) else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }

            let todoItem = TodoItem(documentID: documentID, userID: userID, rank: rank, title: title, completed: completed)
            oncompletion(todoItem, nil)

        } catch {
            oncompletion(nil, error)
        }
    }

    public func delete(withUserID: String?, withDocumentID: String, oncompletion: @escaping(Error?) -> Void) {
        
        let userID = withUserID ?? defaultUsername
        let query = "DELETE FROM todos WHERE user_id='\(userID)' AND tid=\(withDocumentID);"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.CommandOK else {
                oncompletion(TodoCollectionError.ParseError)
                return
            }
            oncompletion(nil)

        } catch {
            oncompletion(error)
        }
    }
}
