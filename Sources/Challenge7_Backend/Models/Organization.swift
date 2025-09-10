//
//  Organization.swift
//  Challenge7_Backend
//
//  Created by Pedro Augusto on 09/09/25.
//
import Fluent

final class Organization: Model, @unchecked Sendable {    
    static let schema = "TB_organizations"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "token")
    var token: String
    
    init () {}
    
    init(id: UUID? = nil, name: String, token: String) {
        self.id = id
        self.name = name
        self.token = token
    }
    
    func toDTO() -> OrganizationDTO {
        .init(
            name: self.name,
            token: self.token
        )
    }
}
