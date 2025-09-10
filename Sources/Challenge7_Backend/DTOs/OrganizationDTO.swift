//
//  OrganizationDTO.swift
//  Challenge7_Backend
//
//  Created by Pedro Augusto on 09/09/25.
//

import Foundation
import Fluent
import Vapor

struct OrganizationDTO: Content {
    var id: UUID?
    var name: String?
    var token: String?
}

extension OrganizationDTO {
    struct Create: Content {
        var name: String?
        var token: String?
    }
}
