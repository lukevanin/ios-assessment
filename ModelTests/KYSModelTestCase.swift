//
//  KYSModelTestCase.swift
//  HornetAssessmentTests
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import XCTest

@testable import Model


private typealias MockError = String

extension MockError: Error {
    
}


private final class MockService: IKYSService {
    typealias GetStatus = (IKYSService.GetStatusCompletion) -> Void
    typealias PostStatus = (KYSStatus, IKYSService.PostStatusCompletion) -> Void
    var _getStatus: GetStatus = { _ in XCTFail("Unexpected call to getStatus") }
    var _postStatus: PostStatus = { _, _ in XCTFail("Unexpected call to postStatus") }
    func getStatus(completion: @escaping IKYSService.GetStatusCompletion) {
        _getStatus(completion)
    }
    func postStatus(status: KYSStatus, completion: @escaping IKYSService.PostStatusCompletion) {
        _postStatus(status, completion)
    }
}


class KYSModelTestCase: XCTestCase {
    
    // MARK: - Check

    func testCheckUpToDate() {
        let service = MockService()
        let model = KYSModel(
            service: service
        )
        service._getStatus = { completion in
            let profile = KYSProfile(
                status: .negative,
                validity: .current
            )
            completion(.success(profile))
        }
        await(model: model, event: .upToDate) {
            model.check()
        }
    }

    func testCheckNotUpToDate() {
        let service = MockService()
        let model = KYSModel(
            service: service
        )
        service._getStatus = { completion in
            let profile = KYSProfile(
                status: .negative,
                validity: .outdated
            )
            completion(.success(profile))
        }
        await(model: model, event: .prompt) {
            model.check()
        }
    }

    func testCheckError() {
        let service = MockService()
        let model = KYSModel(
            service: service
        )
        service._getStatus = { completion in
            completion(.failure("error"))
        }
        await(model: model, event: .failed) {
            model.check()
        }
    }
    
    // MARK: - Prompt
    
    func testPromptCancel() {
        let service = MockService()
        let model = KYSModel(
            service: service
        )
        model.gotoPromptState()
        await(model: model, event: .postponed) {
            model.cancel()
        }
    }

    func testPromptUpdate() {
        let service = MockService()
        let model = KYSModel(
            service: service
        )
        model.gotoPromptState()
        await(model: model, event: .update) {
            model.update()
        }
    }
    
    // MARK: - Update
    
    func testUpdateCancel() {
        let service = MockService()
        let model = KYSModel(
            service: service
        )
        model.gotoUpdateState()
        await(model: model, event: .cancelled) {
            model.cancel()
        }
    }
    
    func testUpdateSave() {
        let service = MockService()
        let model = KYSModel(
            service: service
        )
        model.gotoUpdateState()
        let x = expectation(description: "post-status")
        service._postStatus = { status, _ in
            XCTAssertEqual(status, .negative)
            x.fulfill()
        }
        await(model: model, event: .save) {
            model.save(status: .negative)
        }
        wait(for: [x], timeout: 1.0)
    }
    
    // MARK: - Save
    
    func testSaveFailure() {
        let service = MockService()
        let model = KYSModel(
            service: service
        )
        model.gotoUpdateState()
        service._postStatus = { _, completion in
            completion(false)
        }
        await(model: model, event: .failed) {
            model.gotoSaveState(status: .negative)
        }
    }
    
    func testSaveSuccess() {
        let service = MockService()
        let model = KYSModel(
            service: service
        )
        model.gotoUpdateState()
        service._postStatus = { _, completion in
            completion(true)
        }
        await(model: model, event: .updated) {
            model.gotoSaveState(status: .negative)
        }
    }

    // Utils
    
    private func await(model: KYSModel, event: KYSEvent, block: () -> Void) {
        let x = expectation(description: "event")
        model.onEvent = { e in
            switch e {
            case event:
                x.fulfill()
            default:
                break
            }
        }
        block()
        wait(for: [x], timeout: 1)
    }
}
