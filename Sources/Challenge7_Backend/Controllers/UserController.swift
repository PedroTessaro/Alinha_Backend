
//
//  File.swift
//  Challenge7_Backend
//
//  Created by João Vitor Rocha Miranda on 19/08/25.
//

import Vapor
import Fluent

struct UserController: RouteCollection{
    
    /// initializes all gates
    /// - Parameter routes: builds routes
    func boot(routes: any RoutesBuilder) throws{
        let users = routes.grouped("users")
        
        users.get(use: index)
        users.post(use: create)
        users.patch("updateName", use: updateUserName)
        users.patch("updateUserAvailable", use: updateUserAvailable)
        let authenticatedId = users.grouped(User.authenticator())
        let secured = authenticatedId.grouped(AdminOnlyMiddleware())
        secured.patch("updateRole", use: updateUserRole)
       
        users.group(":id"){ user in
            let authenticatedId = user.grouped(User.authenticator())
            let secured = authenticatedId.grouped(AdminOnlyMiddleware())
            user.get(use: show)
            secured.delete(use: delete)
            
        }
        let passwordProtected = users.grouped(User.authenticator())
        passwordProtected.post("login") { req -> User in
            try req.auth.require(User.self)
        }
    }
    
    /// Fetches all users in data base
    /// - Parameter req: HTTP Request
    /// - Returns: A list of usersDTO
    func index(req: Request) async throws -> [UserDTO] {
        try await User.query(on: req.db).all().map { $0.toDTO() }
    }
    
    /// Creates a new user in data base
    /// - Parameter req: HTTP Request
    /// - Returns: userDTO
    @Sendable
    func create(req: Request) async throws -> User.Public {
        try UserDTO.Create.validate(content: req)
        let create = try req.content.decode(UserDTO.Create.self)
        guard create.password == create.confirmedPassword else{
            throw Abort(.badRequest, reason: "password doesn't match")
        }
        
        let user = try User(
            name: create.name,
            email: create.email,
            available: false,
            password: Bcrypt.hash(create.password),
            role: create.role
        )
        
        try await user.save(on: req.db)
        return user.convertToPublic()
    }
}

/// Requets all users
/// - Parameter req: HTTP Request
/// - Returns: UserDTO
func show(req: Request) async throws -> UserDTO {
    guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
        throw Abort(.notFound)
    }
    return user.toDTO()
}

/// Updates a user's name
/// Expects JSON body: { "id": UUID, "name": String }
func updateUserName(req: Request) async throws -> UserDTO {
    // Define a minimal request body
    struct UpdateNameBody: Content {
        let id: UUID
        let name: String
    }
    // Decode request body
    let body = try req.content.decode(UpdateNameBody.self)
    
    // Find the user by ID
    guard let user = try await User.find(body.id, on: req.db) else {
        throw Abort(.notFound, reason: "User not found")
    }
    
    // Update and persist
    user.name = body.name
    try await user.update(on: req.db)
    
    // Return updated DTO
    return user.toDTO()
}

func updateUserAvailable(req: Request) async throws -> UserDTO {
    // Decode request body
    let body = try req.content.decode(UserDTO.UpdateAvailableRequest.self)
    
    // Find the user by ID
    guard let user = try await User.find(body.id, on: req.db) else {
        throw Abort(.notFound, reason: "User not found")
    }
    
    // Update and persist
    user.available = body.available
    try await user.update(on: req.db)
    
    // Return updated DTO
    return user.toDTO()
}

func updateUserRole(req: Request) async throws -> UserDTO {
    // Decode request body
    let body = try req.content.decode(UserDTO.UpdateRoleRequest.self)
    
    // Find the user by ID
    guard let user = try await User.find(body.id, on: req.db) else {
        throw Abort(.notFound, reason: "User not found")
    }
    
    // Update and persist
    user.role = body.role
    try await user.update(on: req.db)
    
    // Return updated DTO
    return user.toDTO()
}



/// Deletes an user object
/// - Parameter req: HTTP Request
/// - Returns: HTTP code
func delete(req: Request) async throws -> HTTPStatus {
    guard let user = try await User.find(req.parameters.get("id"), on: req.db) else {
        throw Abort(.notFound)
    }
    try await user.delete(on: req.db)
    return .ok
}
