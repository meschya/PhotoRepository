import Foundation
import UIKit

final class NetworkingManager {
    // MARK: - Shared

    static let shared = NetworkingManager()
    
    // MARK: - Enum
    
    // MARK: Private
    
    private enum APIError: Error {
        case noDataReturned
        case invalidURL
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Get commands
    
    public func getPersonInfo(completion: @escaping (Result<PersonInfo, Error>) -> Void) {
        request(url: url(for: .task),
                expecting: PersonInfo.self,
                completion: completion)
    }
    
    // MARK: - Helpers
    
    // MARK: Private
    
    private func url(for endpoint: Endpoint) -> URL? {
        let urlString = Constants.baseUrl.rawValue + endpoint.rawValue
        return URL(string: urlString)
    }
    
    private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
