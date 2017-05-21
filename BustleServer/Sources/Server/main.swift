import Foundation

import Kitura
import HeliumLogger
import LoggerAPI
import Configuration
import CloudFoundryConfig
import TodoList

Log.logger = HeliumLogger()

extension TodoList {
    
    public convenience init(config: PostgreSQLService) {
        
        self.init(host: config.host,
                  port: Int32(config.port),
                  username: config.username,
                  password: config.password)
    }
}

let todos: TodoList

let manager = ConfigurationManager()

do {
    
    manager.load(.environmentVariables)
    
    let postgresConfig = try manager.getPostgreSQLService(name: "TodoList-postgresql")
    todos = TodoList(config: postgresConfig)
}
catch {
    todos = TodoList()
}

let controller = TodoListController(backend: todos)

let port = manager.port
Log.verbose("Assigned port is \(port)")

Kitura.addHTTPServer(onPort: port, with: controller.router)
Kitura.run()