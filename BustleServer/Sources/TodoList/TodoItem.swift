
public struct TodoItem {

    /// ID
    public let documentID: String

    //User
    public let userID: String?

    // Rank
    public let rank: Int

    /// Text to display
    public let title: String

    /// Whether completed or not
    public let completed: Bool

    public init(documentID: String, userID: String? = nil, rank: Int, title: String, completed: Bool) {
        self.documentID = documentID
        self.userID = userID
        self.rank = rank
        self.title = title
        self.completed = completed
    }

}


extension TodoItem : Equatable { }

public func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
    return lhs.documentID == rhs.documentID && lhs.userID == rhs.userID && lhs.rank == rhs.rank &&
        lhs.title == rhs.title && lhs.completed == rhs.completed

}
