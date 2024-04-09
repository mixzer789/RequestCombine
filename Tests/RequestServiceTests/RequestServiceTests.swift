import XCTest
import Combine
import Moya

@testable import RequestService

final class RequestServiceTests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []


    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }


    func test_setUser_shouldLogin_witoutError() {
        let provider = generateProvider(responeCode: 200)
        let expectation = XCTestExpectation(description: "State is set to populated")

        let authAPI = AuthAPI.login(LoginRequestModel(username: "kminchelle", password: "0lelplR"))

        APIManager.request(NetworkRouter(authAPI),provider).sink { complete in
            if case .failure(let _error) = complete {

            }
        } receiveValue: { respone in
            let data: UserResponeModel = respone
            XCTAssertTrue(!data.token.isEmpty)
            expectation.fulfill()
        }
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }



    func test_callAPI_witoutError() {

        let provider = generateProvider(responeCode: 200)
        let expectation = XCTestExpectation(description: "State is set to populated")

        APIManager.request(NetworkRouter(MockRouter()),provider).sink { complete in
            if case .failure(let _error) = complete {

            }
        } receiveValue: { respone in
            let tokenRespone: TokenRespone = respone
            XCTAssertTrue(!tokenRespone.acessToken.isEmpty)
            expectation.fulfill()
        }
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }



    func test_callAPI_withTokenInvalidError() {


        let provider = generateProvider(responeCode: 401)
        let expectation = XCTestExpectation(description: "State is set to populated")

        APIManager.request(NetworkRouter(MockRouter()),provider).sink { complete in
            if case .failure(let _error) = complete {
                XCTAssertEqual(_error.errorCode, 401)
                expectation.fulfill()
            }
        } receiveValue: { respone in
            let tokenRespone: TokenRespone = respone
            XCTAssertTrue(!tokenRespone.acessToken.isEmpty)
            expectation.fulfill()
        }
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)

    }


   private func generateProvider(responeCode: Int) -> MoyaProvider<NetworkRouter> {

        let endpoint = { (target: NetworkRouter) -> Endpoint in
            return Endpoint(url: "mock.call",
                            sampleResponseClosure: { .networkResponse(responeCode, target.sampleData) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }

       return MoyaProvider<NetworkRouter>(endpointClosure: endpoint,stubClosure: MoyaProvider.immediatelyStub,session: Session(interceptor: AuthInterceptor.shared),plugins: [VerbosePlugin(verbose: true)])

    }
}
