//
//  FeedItem.swift
//  SugarBox_Demo
//
//  Created by Prithviraj Patil on 26/09/23.
//

import Foundation

struct ScreenData: Codable {
    let data: [PageData]
}

struct PageData: Codable {
    let id, contentID, createdAt, description: String
    let title, updatedAt: String
    let contents: [Content]
    let dateID, addedOn: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case contentID = "contentId"
        case createdAt, description, title, updatedAt, contents
        case dateID = "id"
        case addedOn
    }
}

struct Content: Codable {
    let id, contentID: String
    let assets: [Asset]
    let contentType: ContentType
    let description: String
    let metaData: MetaData
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case contentID = "contentId"
        case assets, contentType, description, metaData
        case title
    }
}

struct Asset: Codable {
    let assetType: AssetType
    let sourceURL: String
    let type: TypeEnum
    let sourcePath: String
    
    enum CodingKeys: String, CodingKey {
        case assetType
        case sourceURL = "sourceUrl"
        case type, sourcePath
    }
}

enum AssetType: String, Codable {
    case image = "IMAGE"
    case video = "VIDEO"
}

enum TypeEnum: String, Codable {
    case dash = "dash"
    case detail = "detail"
    case hls = "hls"
    case thumbnail = "thumbnail"
    case thumbnailList = "thumbnail_list"
}

enum ContentType: String, Codable {
    case movie = "Movie"
    case show = "Show"
}

struct MetaData: Codable {
    let duration: Int
    let isNonCompressed: Bool
    let episodeNumber: Int
    let enableDownloadOnDongle, hasAssets, shouldHaveChildren: Bool
    
    enum CodingKeys: String, CodingKey {
        case duration, isNonCompressed
        case episodeNumber = "episode_number"
        case enableDownloadOnDongle, hasAssets, shouldHaveChildren
    }
}
