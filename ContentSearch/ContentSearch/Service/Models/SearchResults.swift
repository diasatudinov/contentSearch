//
//  SearchResults.swift
//  ContentSearch
//
//  Created by Dias Atudinov on 09.09.2024.
//

import Foundation

struct SearchResults: Decodable {
    let total: Int
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Decodable {
    let width: Int
    let height: Int
    let likes: Int
    let description: String?
    let user : User
    let urls: [URLKing.RawValue: String]
    
    enum URLKing: String {
        case raw
        case full
        case regular
        case small
        case thumb
    }
}

struct User: Decodable {
    let id, username, name, firstName: String?
    let lastName, instagramUsername, twitterUsername: String?
    let portfolioURL: String?

    enum CodingKeys: String, CodingKey {
        case id, username, name
        case firstName = "first_name"
        case lastName = "last_name"
        case instagramUsername = "instagram_username"
        case twitterUsername = "twitter_username"
        case portfolioURL = "portfolio_url"
    }
}
