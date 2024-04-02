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

    public init(){}

    static var cancelable = Set<AnyCancellable>()

    public static func request<T: Codable>(_ router: NetworkRouter) -> AnyPublisher<T , Error>{
        Future<T, Error> {promise in
            let apis = router
            let provider = MoyaProvider<NetworkRouter>( plugins: [
                VerbosePlugin(verbose: true)
            ])
            provider.requestPublisher(apis)
                .sink(receiveCompletion: { completion in
                    switch completion{
                        case .finished:
                            print("RECEIVE VALUE COMPLETED")
                        case .failure:
                            print("RECEIVE VALUE FAILED")
                    }
                }, receiveValue: { response in
                    guard let  result = try? JSONDecoder().decode(BaseRespone<T>.self, from: response.data) else {return}
                    guard let data = result.data else {return}
                    promise(.success(data))
                })
                .store(in: &cancelable)

        }.eraseToAnyPublisher()
    }
}




struct VerbosePlugin: PluginType {
    let verbose: Bool
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
#if DEBUG
        NetworkLogger.log(request: request)
#endif
        return request
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
#if DEBUG
        switch result {
            case .success(let body):
                if verbose {
                    NetworkLogger.log(response:body.response, data: body)
                }
            case .failure( _):
                break
        }
#endif
    }

}
