
import Foundation

public enum TodoCollectionError: Error {

    case ConnectionRefused
    case IDNotFound(String)
    case CreationError(String)
    case ParseError
    case AuthError
}
