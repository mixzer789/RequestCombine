//
//  File.swift
//  
//
//  Created by Sittichai Chumjai on 8/4/2567 BE.
//

import Foundation
import Moya

public class MockRouter: TargetType{

    public var baseURL: URL{
        switch self{
            default:
                return URL(string: "https://dummyjson.com")!
        }
    }

    public var path: String {
        return "/auth/me"
    }

    public var method: Moya.Method {
        return .get
    }

    public var task: Moya.Task {
        let params: [String: Any] = [:]
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }

    public var headers: [String : String]? {
        var header :[String:String] = [:]
        header["Content-Type"] = "application/json"
        return header
    }

    public var validationType: ValidationType{
        return .successCodes
    }

    public var sampleData: Data {
        let mockToken = TokenRespone(acessToken: UUID().uuidString,
                                     refreshToken: UUID().uuidString,
                                     expireIn: 3600)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let result = try encoder.encode(mockToken)
            // RESULT IS NOW JSON-LIKE DATA OBJECT
            return result
        } catch {
            print("Your parsing sucks \(error)")
            return Data()
        }

    }
}

    

