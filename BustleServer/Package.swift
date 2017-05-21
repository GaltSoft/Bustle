
import PackageDescription

let package = Package(
    name: "TodoList",
    targets: [
        Target(
            name: "Server",
            dependencies: [.Target(name: "TodoList")]
        ),
        Target(
            name: "TodoList"
        )
    ],
    dependencies: [
         .Package(url: "https://github.com/IBM-Swift/Kitura.git",               majorVersion: 1),
         .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git",         majorVersion: 1),
         .Package(url: "https://github.com/Zewo/PostgreSQL.git",                    majorVersion: 0),
         .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git",   majorVersion: 4)
    ]
)