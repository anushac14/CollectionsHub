//  Link.swift
//  CollectionsHub

import Foundation

struct Link: Decodable, Identifiable {
    let id: UUID
    let folder_id: UUID
    let link: String
}
