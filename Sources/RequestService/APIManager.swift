//
//  APIManager.swift
//  moive
//
//  Created by Sittichai Chumjai on 16/3/2567 BE.
//

import Foundation
import Combine
import Moya
import CombineMoya

public struct APIManager{

    public init(){
    }

    static var cancelable = Set<AnyCancellable>()

    public static func request<T: Codable>(_ router: NetworkRouter,_ provider: MoyaProvider<NetworkRouter>? = nil) -> AnyPublisher<T , AppError>{
        Future<T, AppError> {promise in
            var requestProvider: MoyaProvider<NetworkRouter>!
            let apis = router
            if let _provider = provider {
                requestProvider = _provider
            }else {
                requestProvider = MoyaProvider<NetworkRouter>(session: Session(interceptor: AuthInterceptor.shared),
                                                              plugins: [VerbosePlugin(verbose: true)])
            }
            requestProvider.requestPublisher(apis)
                .sink(receiveCompletion: { completion in
                    switch completion{
                        case .finished:
                            print("RECEIVE VALUE COMPLETED")
                        case .failure(let error):
                            print("RECEIVE VALUE FAILED")
                            promise(.failure(.init(error:error)))
                    }
                }, receiveValue: { response in
                    guard let  result = try? JSONDecoder().decode(BaseRespone<T>.self, from: response.data),
                          let data = result.data else {
                        promise(.failure(.init(type: .undecode)))
                        return
                    }
                    promise(.success(data))
                })
                .store(in: &cancelable)

        }
        .retry(3)
        .eraseToAnyPublisher()

    }
}




