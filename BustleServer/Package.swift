
import PackageDescription

let package = Package(
    name: "BustleServer",
    targets: [
        Target(
            name: "Server",
            dependencies: [.Target(name: "BustleServices")]
        ),
        Target(
            name: "BustleServices"
        )
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git",                majorVersion: 1),
        .Package(url: "https://github.com/davidungar/miniPromiseKit",           majorVersion: 4),
        .Package(url: "https://github.com/IBM-Swift/Kitura-CouchDB.git",        majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/CloudConfiguration.git",    majorVersion: 2),
        .Package(url: "https://github.com/IBM-Bluemix/cf-deployment-tracker-client-swift.git", majorVersion: 3)
    ]
)
