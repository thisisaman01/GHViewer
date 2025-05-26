//
//  CacheService.swift
//  GHViewer
//
//  Created by Admin on 26/05/25.
//

import Foundation
import UIKit

class CacheService {
    static let shared = CacheService()
    private init() {}
    
    private let imageCache = NSCache<NSString, UIImage>()
    private let userDefaults = UserDefaults.standard
    
    // Image Caching
    func cacheImage(_ image: UIImage, forKey key: String) {
        imageCache.setObject(image, forKey: key as NSString)
    }
    
    func getCachedImage(forKey key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
    
    // Search History
    func saveSearchHistory(_ username: String) {
        var history = getSearchHistory()
        let newEntry = SearchHistory(username: username, searchDate: Date())
        
        // Remove existing entry if it exists
        history.removeAll { $0.username.lowercased() == username.lowercased() }
        
        // Add new entry at the beginning
        history.insert(newEntry, at: 0)
        
        // Keep only last 10 searches
        if history.count > 10 {
            history = Array(history.prefix(10))
        }
        
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: "SearchHistory")
        }
    }
    
    func getSearchHistory() -> [SearchHistory] {
        guard let data = userDefaults.data(forKey: "SearchHistory"),
              let history = try? JSONDecoder().decode([SearchHistory].self, from: data) else {
            return []
        }
        return history
    }
    
    func clearSearchHistory() {
        userDefaults.removeObject(forKey: "SearchHistory")
    }
}
