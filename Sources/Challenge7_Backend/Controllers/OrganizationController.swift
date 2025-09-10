//
//  File.swift
//  Challenge7_Backend
//
//  Created by Pedro Augusto on 10/09/25.
//

import Foundation
import Vapor
import Fluent

struct OrganizationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let organizations = routes.grouped("organizations")
        
        organizations.post(use: create)
        organizations.delete(use: remove)
    }
    
    @Sendable
    func create(req: Request) async throws -> OrganizationDTO.Create {
        let body = try? req.content.decode(OrganizationDTO.Create.self)
        
        guard let name = body?.name else {
            throw Abort(.badRequest, reason: "Organization name was not informed")
        }
        
        guard let token = body?.token else {
            throw Abort(.badRequest, reason: "Organization token was not informed")
        }
        
        let organization = Organization(name: name, token: token)
        try await organization.save(on: req.db)
        
        let organizationDTOCreate = OrganizationDTO.Create(name: name, token: token)
        
        return organizationDTOCreate
    }
    
    @Sendable
    func remove(req: Request) async throws -> HTTPStatus {
        
        let body = try req.content.decode(OrganizationDTO.self)
        
        guard let id = body.id else {
            throw Abort(.badRequest, reason: "Organization name was not informed")
        }
        
        guard let name = body.name else {
            throw Abort(.badRequest, reason: "Organization name was not informed")
        }
        
        guard let token = body.token else {
            throw Abort(.badRequest, reason: "Organization token was not informed")
        }
        
        let organization = Organization(id: id, name: name, token: token)
        try await organization.delete(on: req.db)
        
        return .ok
    }
}
