//
//  GitHubUser.swift
//  GHViewer
//
//  Created by Admin on 26/05/25.
//

import Foundation

struct GitHubUser: Codable {
    let login: String
    let name: String?
    let avatarUrl: String
    let publicRepos: Int
    let bio: String?
    let location: String?
    let company: String?
    let followers: Int
    let following: Int
    let email: String?
    let blog: String?
    let twitterUsername: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case login
        case name
        case avatarUrl = "avatar_url"
        case publicRepos = "public_repos"
        case bio
        case location
        case company
        case followers
        case following
        case email
        case blog
        case twitterUsername = "twitter_username"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var joinedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let date = formatter.date(from: createdAt) {
            formatter.dateFormat = "MMM yyyy"
            return "Joined \(formatter.string(from: date))"
        }
        return ""
    }
}

struct GitHubRepository: Codable {
    let name: String
    let description: String?
    let language: String?
    let stargazersCount: Int
    let forksCount: Int
    let isPrivate: Bool
    let htmlUrl: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case language
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case isPrivate = "private"
        case htmlUrl = "html_url"
        case updatedAt = "updated_at"
    }
}

struct SearchHistory: Codable {
    let username: String
    let searchDate: Date
}

enum GitHubError: Error {
    case userNotFound
    case networkError
    case invalidURL
    case decodingError
    case rateLimitExceeded
    
    var localizedDescription: String {
        switch self {
        case .userNotFound:
            return "User not found. Please check the username and try again."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .invalidURL:
            return "Invalid URL."
        case .decodingError:
            return "Error processing data."
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        }
    }
}

