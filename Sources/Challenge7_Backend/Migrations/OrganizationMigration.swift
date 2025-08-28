//
//  OrganizationMigration.swift
//  Challenge7_Backend
//
//  Created by Enzo Ferroni on 20/08/25.
//
//OLD COLDE
import Fluent

// MARK: - Organization Migration
struct OrganizationMigration: AsyncMigration {
    
    // MARK: - Public Methods
    
    /// Creates the organization table in the database
    /// - Parameter database: Database connection where the table will be created
    func prepare(on database: any Database) async throws {
        try await database.schema("TB_organizations")
            .id()
            .field("name", .string, .required)
            .field("token", .string, .required)
            .field("appointment_places", .array(of: .string), .required)
            .field("first_user_id", .uuid, .required, .references("TB_users", "id", onDelete: .restrict))
            .field("available_mentors", .array(of: .uuid), .required)
            .field("queue", .array(of: .uuid), .required)
            .field("unschedule_queue", .array(of: .uuid), .required)
            .field("appointment_id", .uuid, .references("TB_appointments", "id", onDelete: .setNull))
            .unique(on: "token")
            .create()
    }
    
    /// Removes the organization table from the database
    /// - Parameter database: Database connection where the table will be removed
    func revert(on database: any Database) async throws {
        try await database.schema("TB_organizations").delete()
    }
}
