//
//  GitHubService.swift
//  GHViewer
//
//  Created by Admin on 26/05/25.
//

import Foundation

class GitHubService {
    static let shared = GitHubService()
    private init() {}
    
    private let baseURL = "https://api.github.com"
    private let session = URLSession.shared
    
    func fetchUser(username: String) async throws -> GitHubUser {
        guard let url = URL(string: "\(baseURL)/users/\(username)") else {
            throw GitHubError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GitHubError.networkError
            }
            
            switch httpResponse.statusCode {
            case 200:
                let user = try JSONDecoder().decode(GitHubUser.self, from: data)
                return user
            case 404:
                throw GitHubError.userNotFound
            case 403:
                throw GitHubError.rateLimitExceeded
            default:
                throw GitHubError.networkError
            }
        } catch let error as GitHubError {
            throw error
        } catch {
            if error is DecodingError {
                throw GitHubError.decodingError
            } else {
                throw GitHubError.networkError
            }
        }
    }
    
    func fetchRepositories(username: String, page: Int = 1, perPage: Int = 10) async throws -> [GitHubRepository] {
        guard let url = URL(string: "\(baseURL)/users/\(username)/repos?page=\(page)&per_page=\(perPage)&sort=updated") else {
            throw GitHubError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GitHubError.networkError
            }
            
            switch httpResponse.statusCode {
            case 200:
                let repos = try JSONDecoder().decode([GitHubRepository].self, from: data)
                return repos
            case 404:
                throw GitHubError.userNotFound
            case 403:
                throw GitHubError.rateLimitExceeded
            default:
                throw GitHubError.networkError
            }
        } catch let error as GitHubError {
            throw error
        } catch {
            if error is DecodingError {
                throw GitHubError.decodingError
            } else {
                throw GitHubError.networkError
            }
        }
    }
}













//import Foundation
//
//class GitHubService {
//    static let shared = GitHubService()
//    private init() {}
//
//    private let baseURL = "https://api.github.com/users/"
//
//    func fetchUser(username: String) async throws -> GitHubUser {
//        guard let url = URL(string: baseURL + username) else {
//            throw GitHubError.invalidURL
//        }
//
//        do {
//            let (data, response) = try await URLSession.shared.data(from: url)
//
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw GitHubError.networkError
//            }
//
//            switch httpResponse.statusCode {
//            case 200:
//                let user = try JSONDecoder().decode(GitHubUser.self, from: data)
//                return user
//            case 404:
//                throw GitHubError.userNotFound
//            default:
//                throw GitHubError.networkError
//            }
//        } catch let error as GitHubError {
//            throw error
//        } catch {
//            if error is DecodingError {
//                throw GitHubError.decodingError
//            } else {
//                throw GitHubError.networkError
//            }
//        }
//    }
//}
