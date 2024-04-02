# RequestService

RequestService is a Swift library , Network layer and Loging by Combine and Moya 

## Installation

Use the swift package manager to install.

```bash
.package(url: "https://github.com/mixzer789/RequestCombine", .upToNextMajor(from: "0.0.1"))
```

## Prepare

after completed install swift package manager

```
import Moya
import RequestService
```


## Create API file

1. Create API Enum for Request

```
public enum CoinAPI {
    case listOfCoins(_ model: ListOfCoinRequest?)
    case descriptionOfCoint(coinId:String)
}
```

2. Conform TragetType to Enum and config them
```
extension CoinAPI: TargetType{

    public var baseURL: URL{
        switch self{
            default:
                return URL(string: "https://api.coinranking.com:/v2")!
        }
    }

    public var path: String {
        switch self {
            case .listOfCoins(_):
                return "/coins"
            case .descriptionOfCoint(coinId: let coinId):
                return "coin/\(coinId)"
        }
    }

    public var method: Moya.Method {
        switch self {
            case .listOfCoins:
                return .get
            case .descriptionOfCoint(coinId: _):
                return .get
        }
    }

    public var task: Moya.Task {
        switch self {
            case .listOfCoins(let model):
                let params = try? model.json()
                return .requestParameters(parameters: params ?? [:], encoding: URLEncoding.default)
            default:
                let params: [String: Any] = [:]
                return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }

    public var headers: [String : String]? {
        var header :[String:String] = [:]
        switch self {
            default:
                header["Content-Type"] = "application/json"
        }
        return header
    }
}

```
3. Add Some Extension for more easy

```
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
```
## Create Worker

```
import Combine
import RequestService

protocol APIServiceProtocol {
    func fetchCoin(currentOffset: Int?) -> AnyPublisher<ListOfCoinRespone, Error>
    func searchCoin(keyword: String?,currentOffset: Int?) -> AnyPublisher<ListOfCoinRespone, Error>
    func coinDetaile(coinID: String) -> AnyPublisher<ListOfCoinRespone, Error>
}



class ServiceWorker: APIServiceProtocol{
    func coinDetaile(coinID: String) -> AnyPublisher<ListOfCoinRespone, Error> {

        let api = CoinAPI.descriptionOfCoint(coinId: coinID)
        let networkRouter = NetworkRouter(api)

        return APIManager.request(networkRouter)
    }
    
    func fetchCoin(currentOffset: Int?) -> AnyPublisher<ListOfCoinRespone, Error> {
        
        let requestModel = ListOfCoinRequest(offset: currentOffset)
        let api = CoinAPI.listOfCoins(requestModel)
        let networkRouter = NetworkRouter(api)

        return APIManager.request(networkRouter)

    }
    
    func searchCoin(keyword: String?,currentOffset: Int?) -> AnyPublisher<ListOfCoinRespone, Error> {

        let requestModel = ListOfCoinRequest(keyword: keyword,offset: currentOffset)
        let api = CoinAPI.listOfCoins(requestModel)
        let networkRouter = NetworkRouter(api)

        return APIManager.request(networkRouter)

    }

}
```

## Usage
```
import Combine
import RequestService


class CoinListViewModel: ObservableObject {
    @Published var listOfCoin: [Coin] = []

    private var cancellables: Set<AnyCancellable> = []

    private let service: ServiceWorker

    init(service: ServiceWorker) {
        self.service = service
    }

func fetchCoin() {
        service.fetchCoin(currentOffset: currentOffset).sink { completion in
            if case .failure(let error) = completion {
                                print("Error: \(error.localizedDescription)")
                            }
        } receiveValue: { [weak self] respone in
            self?.listOfCoin += respone.coins.compactMap{ coin in
                return self?.setupCoinData(coin: coin)
            }
        }
        .store(in: &cancellables)

    }
```



## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)
