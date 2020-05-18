//
//  GitRepoBO.swift
//  Challenge
//
//  Created by Suraj Kodre on 15/05/20.
//  Copyright © 2020 Suraj Kodre. All rights reserved.
//

import Foundation

struct GitRepoBO: Codable {
    let userName: String
    let repoScore: Double?
    let repoImage: String?
    
//    enum CodingKeys: String, CodingKey {
//        case userName = "login"
//        case repoScore = "score"
//        case repoImage = "avatar_url"
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        userName = try (values.decodeIfPresent(String.self, forKey: .userName) ?? "")
//        repoScore = try values.decodeIfPresent(Double.self, forKey: .repoScore)
//        repoImage = try values.decodeIfPresent(String.self, forKey: .repoImage)
//    }
}
