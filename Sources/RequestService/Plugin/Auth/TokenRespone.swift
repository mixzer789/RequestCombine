//
//  File.swift
//  
//
//  Created by Sittichai Chumjai on 8/4/2567 BE.
//

import Foundation
import SwiftUI

public struct TokenRespone: Codable{
    public var acessToken: String
    public var refreshToken: String
    public var expireIn: Int


    enum CodingKeys: String, CodingKey {
        case acessToken = "access_token"
        case refreshToken = "refresh_token"
        case expireIn = "expires_in"

    }
}



public struct LoginRequestModel: Codable{
    public var username: String
    public var password: String
    public var expireIn: Int?

    enum CodingKeys: String, CodingKey {
        case username
        case password
        case expireIn = "expiresInMins"

    }
}


public struct UserResponeModel: Codable {
    let id: Int
    let username, email, firstName, lastName: String
    let gender: String
    let image: String
    let token: String
}


