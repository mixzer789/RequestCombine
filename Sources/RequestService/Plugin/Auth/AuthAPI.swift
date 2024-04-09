//
//  File.swift
//  
//
//  Created by Sittichai Chumjai on 8/4/2567 BE.
//

import Foundation
import Moya


public enum AuthAPI {
    case login(_ loginModel: LoginRequestModel)
    case user
    case refesh
}


extension AuthAPI: TargetType{

    public var baseURL: URL{
        switch self{
            default:
                return URL(string: "https://dummyjson.com")!
        }
    }

    public var path: String {
        switch self{
            case .login:
                return "/auth/login"
            case .user:
                return "/auth/me"
            case .refesh:
                return "/auth/refresh"
        }
    }

    public var method: Moya.Method {
        switch self{
            case .login:
                return .post
            case .user:
                return .get
            case .refesh:
                return .post
        }
    }

    public var task: Moya.Task {
        switch self{
            case .login(let model):
                return .requestJSONEncodable(model)
            case .user:
                return .requestParameters(parameters: [:], encoding: URLEncoding.default)
            case .refesh:
                return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        }
    }

    public var headers: [String : String]? {
        var header :[String:String] = [:]
        header["Content-Type"] = "application/json"
        switch self{
            case .user:
                header["Authorization"] = "Bearer \(TokenManager.shared.accessToken ?? "")"
            case .refesh:
                header["Authorization"] = "Bearer \(TokenManager.shared.accessToken ?? "")"
            default:
                break
        }
        return header
    }

    public var validationType: ValidationType{
        return .successCodes
    }

    public var sampleData: Data {
        let mockUser = UserResponeModel(id: 15,
                                        username: "kminchelle",
                                        email: "kminchelle@qq.com",
                                        firstName: "Jeanne",
                                        lastName: "Halvorson",
                                        gender: "male",
                                        image: "",
                                        token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTUsInVzZXJuYW1lIjoia21pbmNoZWxsZSIsImVtYWlsIjoia21pbmNoZWxsZUBxcS5jb20iLCJmaXJzdE5hbWUiOiJKZWFubmUiLCJsYXN0TmFtZSI6IkhhbHZvcnNvbiIsImdlbmRlciI6ImZlbWFsZSIsImltYWdlIjoiaHR0cHM6Ly9yb2JvaGFzaC5vcmcvSmVhbm5lLnBuZz9zZXQ9c2V0NCIsImlhdCI6MTcxMjYzNjE3MiwiZXhwIjoxNzEyNjM5NzcyfQ.cb6k_jw77WH-ZqIfssJVcCeKbU0r7ctIg7VZafHakjk")
        let baseRespone = BaseRespone(status: "", data: mockUser)
        return returnJSONData(baseRespone)
    }

    private func returnJSONData(_ json: Codable) -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let result = try encoder.encode(json)
            // RESULT IS NOW JSON-LIKE DATA OBJECT
            return result
        } catch {
            print("Your parsing sucks \(error)")
            return Data()
        }

    }
}


extension Encodable {
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }

    func json() throws -> [String:Any]? {
        return try? JSONSerialization.jsonObject(with: self.jsonData(), options: []) as? [String: AnyHashable]
    }
    func newJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            encoder.dateEncodingStrategy = .iso8601
        }
        return encoder
    }

    public func convert <T: Codable>() -> T? {
        do {
            let model = try JSONDecoder().decode(T.self, from: jsonData())
            return model
        } catch {
            print(error.localizedDescription)
            return nil
        }

    }
}
