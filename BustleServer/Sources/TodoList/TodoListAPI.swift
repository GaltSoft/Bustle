

public protocol TodoListAPI {
    func count(withUserID: String?, oncompletion: @escaping (Int?, Error?) -> Void)
    func clear(withUserID: String?, oncompletion: @escaping (Error?) -> Void)
    func clearAll(oncompletion: @escaping (Error?) -> Void)
    func get(withUserID: String?, oncompletion: @escaping ([TodoItem]?, Error?) -> Void)
    func get(withUserID: String?, withDocumentID: String, oncompletion: @escaping (TodoItem?, Error?) -> Void )
    func add(userID: String?, title: String, rank: Int, completed: Bool,
    oncompletion: @escaping (TodoItem?, Error?) -> Void )
    func update(documentID: String, userID: String?, title: String?, rank: Int?,
    completed: Bool?, oncompletion: @escaping (TodoItem?, Error?) -> Void )
    func delete(withUserID: String?, withDocumentID: String, oncompletion: @escaping (Error?) -> Void)}
