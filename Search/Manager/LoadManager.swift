import Foundation

class LoadManager {
    static let shared = LoadManager()
    
    private init() {}
    
    func SearchData(query: String, entity: String, completion: @escaping (Result<[SearchItem], Error>) -> Void) {
        if let url = URL(string: "https://itunes.apple.com/search?term=\(query)&entity=\(entity)&limit=30") {

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    completion(.failure(error ?? NSError(domain: "LoadManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(SearchResult.self, from: data)
                    completion(.success(result.results))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
        } else {
            completion(.failure(NSError(domain: "LoadManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка при создании URL"])))
        }
    }
    
}
