import Foundation

struct Person: Codable {
    var photoURL, userURL: String
    let userName: String
    let colors: [String]

    enum CodingKeys: String, CodingKey {
        case photoURL = "photo_url"
        case userURL = "user_url"
        case userName = "user_name"
        case colors
    }
}

typealias PersonInfo = [String: Person]
