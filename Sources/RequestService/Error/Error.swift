//
//  File.swift
//  
//
//  Created by Sittichai Chumjai on 8/4/2567 BE.
//

import Foundation
import Moya
import Alamofire

public protocol ServiceError: AnyObject, Error {
    var errorCode: Int { get set }
    var message : String { get set }
    var type: ServiceErrorType? { get set }
    var byServer: Bool { get set }
}

public enum ServiceErrorType: String {
    case isNull = ""
    case searchNotFound = "SE404"
    case unknown = "unknow"
    case productNotFound = "PD404"
    case cartEmpty = "OR428"
    case couponNotFound = "OR403"
    case sometingWentWorng = "NR500"
    case vpn = "NR403"
    case undecode = "UN000"
}

public class AppError: ServiceError {
    public var errorCode: Int
    public var message: String
    public var type: ServiceErrorType?
    public var byServer: Bool = false

    public required init(errorCode: Int? = 0,type: ServiceErrorType? = .unknown) {
        self.errorCode = errorCode ?? 0
        self.message = type?.rawValue ?? ""
        self.type = type
    }

    public required init(error: MoyaError) {
        self.errorCode = error.response?.statusCode ?? 0
        self.message = error.errorDescription ?? ""
    }

    public required init(error: [String:Any]) {
        self.errorCode = error["statusCode"] as? Int ?? 0
        self.message = error["message"] as? String ?? ""
        self.byServer = true
    }

    public required init(type: ServiceErrorType? = .unknown) {
        self.errorCode =  0
        self.message = type?.rawValue ?? ""
        self.type = type
    }
}

extension Error {
    public var asAppError: AppError? {
        self as? AppError
    }
}
