//
//  OrganizationMigration.swift
//  Challenge7_Backend
//
//  Created by Pedro Augusto on 09/09/25.
//

import Fluent

struct OrganizationMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("TB_organizations")
            .id()
            .field("name", .string, .required)
            .field("token", .string, .required)
            .unique(on: "token")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("TB_organizations").delete()
    }
}
