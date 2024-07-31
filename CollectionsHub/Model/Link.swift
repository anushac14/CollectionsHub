//  Link.swift
//  CollectionsHub

import Foundation

struct Link: Decodable, Identifiable, Encodable {
    let id: UUID
    let folder_id: UUID
    let link: String
}
