//
//  File.swift
//  
//
//  Created by Sittichai Chumjai on 2/4/2567 BE.
//

import Foundation
import Moya

public class NetworkRouter: TargetType {
    public var baseURL: URL
    public var path: String
    public var method: Moya.Method
    public var task: Moya.Task
    public var headers: [String : String]?

    public init(_ api: TargetType) {
        baseURL = api.baseURL
        path = api.path
        method = api.method
        task = api.task
        headers = api.headers
    }
}


