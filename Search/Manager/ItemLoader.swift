import Foundation

class ItemLoader {
    static let shared = ItemLoader()
    
    private init() {}
    
    func loadItems(from data: Data, completion: @escaping ([ItemData]?, Error?) -> Void) {
        do {
            let decoder = JSONDecoder()
            let item = try decoder.decode([ItemData].self, from: data)
            completion(item, nil)
        } catch {
            completion(nil, error)
        }
    }
}
