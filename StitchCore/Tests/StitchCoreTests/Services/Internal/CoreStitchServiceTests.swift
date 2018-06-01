import XCTest
import MongoSwift
@testable import StitchCore

private let appRoutes = StitchAppRoutes.init(clientAppId: "")
private let mockServiceName = "mockService"
private let mockFunctionName = "mockFunction"
private let mockArgs = [0, 1, 2]
private let expectedDoc: Document = [
    "name": mockFunctionName,
    "service": mockServiceName,
    "arguments": mockArgs
]

class CoreStitchServiceTests: XCTestCase {
    
    func testCallFunctionInternal() throws {
        let serviceName = "svc1"
        let routes = StitchAppRoutes.init(clientAppId: "foo").serviceRoutes
        let requestClient = MockStitchAuthRequestClient()
        
        let coreStitchService = CoreStitchServiceImpl.init(
            requestClient: requestClient,
            routes: routes,
            serviceName: serviceName
        )
        
        requestClient.doAuthenticatedRequestWithDecodingMock.doReturn(result: 42, forArg: .any)
        
        let funcName = "myFunc"
        let args = [1, 2, 3]
        var expectedRequestDoc: Document = ["name": funcName, "arguments": args, "service": serviceName]

        XCTAssertEqual(42, try coreStitchService.callFunctionInternal(withName: funcName, withArgs: args))
        
        let functionCallRequest =
            requestClient.doAuthenticatedRequestWithDecodingMock.capturedInvocations[0] as? StitchAuthDocRequest
        
        XCTAssertEqual(functionCallRequest?.method, Method.post)
        XCTAssertEqual(functionCallRequest?.path, routes.functionCallRoute)
        XCTAssertEqual(functionCallRequest?.document, expectedRequestDoc)
    }
}