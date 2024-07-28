//
//  ImageItem.swift
//  CollectionsHub
//
//  Created by Anusha Chinthamaduka on 7/28/24.
//

import SwiftUI
import SwiftData

@Model
class ImageItem{
    @Attribute(.externalStorage)
    var data: Data
    init(data: Data) {
        self.data = data
    }
}
