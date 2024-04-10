//
//  File.swift
//
//
//  Created by Sittichai Chumjai on 8/4/2567 BE.
//

import Foundation
import Alamofire
import Moya
import Combine

public protocol AuthAdapter: RequestInterceptor{}

final class AuthInterceptor: AuthAdapter {

    static let shared = AuthInterceptor()
    private var cancellables: Set<AnyCancellable> = []

    private init() {}

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix("https:") == true,
              let accessToken = TokenManager.accessToken,
              let refreshToken =  TokenManager.refreshToken
        else {
            completion(.success(urlRequest))
            return
        }

        var urlRequest = urlRequest
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))
    }



    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401
        else {
            completion(.doNotRetryWithError(error))
            return
        }
        let api = AuthAPI.refesh
        
        APIManager.request(NetworkRouter(api)).sink { complete in
            if case .failure(_) = complete {
                completion(.doNotRetryWithError(error))
            }
        } receiveValue: { respone in
            let tokenRespone: TokenRespone = respone
            TokenManager.accessToken = tokenRespone.acessToken
            completion(.retry)
        }
        .store(in: &cancellables)
    }

    
}
