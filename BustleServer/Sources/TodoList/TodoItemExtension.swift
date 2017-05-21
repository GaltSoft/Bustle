
import Foundation
import Configuration

typealias JSONDictionary = [String : Any]

let localServerURL = "http://localhost:8080"

protocol DictionaryConvertible {
    func toDictionary() -> JSONDictionary
}

extension TodoItem : DictionaryConvertible {
    var url: String {
        
        let url: String
        
        let manager = ConfigurationManager()
        manager.load(.environmentVariables)
        
        if let configUrl = manager["VCAP_APPLICATION:uris:0"] as? String {
            url = "https://" + configUrl
        }
        else {
            url = manager["url"] as? String ?? localServerURL
        }
        
        return url + "/api/todos/" + documentID
    }
    
    func toDictionary() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"] = self.documentID
        result["user"] = self.userID
        result["order"] = self.rank
        result["title"] = self.title
        result["completed"] = self.completed
        result["url"] = self.url
        return result
    }
}

extension Array where Element : DictionaryConvertible {
    func toDictionary() -> [JSONDictionary] {
        return self.map { $0.toDictionary() }
    }
}
