//
//  MusicModule.swift
//  Music App
//
//  Created by Simran on 03/04/24.
//

import Foundation
// MARK: - Module
struct MusicModule: Codable {
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable {
    let id: Int
    let status: String
    let sort: String?
    let userCreated, dateCreated, userUpdated, dateUpdated: String
    let name, artist, accent, cover: String
    let topTrack: Bool
    let url: String

    enum CodingKeys: String, CodingKey {
        case id, status, sort
        case userCreated = "user_created"
        case dateCreated = "date_created"
        case userUpdated = "user_updated"
        case dateUpdated = "date_updated"
        case name, artist, accent, cover
        case topTrack = "top_track"
        case url
    }
}

//enum Status: String, Codable {
//    case published = "published"
//}


struct Song: Decodable {
    let name: String
    let artist: String
    let cover: String
    enum CodingKeys: String, CodingKey {
        case name, artist, cover
    }
}
