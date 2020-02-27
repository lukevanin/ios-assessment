//
//  KYSModel.swift
//  HornetAssessment
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import Foundation


public enum KYSResult {
    case upToDate
    case userPostponed
    case userCancelled
    case failure
    case success
}


public enum KYSStatus {
    case positive
    case negative
}


public enum KYSEvent {
    case prompt
    case update
    case save
    case updated
    case upToDate
    case cancelled
    case postponed
    case finished
    case failed
}


protocol IState {
    func check()
    func update()
    func cancel()
    func save(status: KYSStatus)
}


protocol IStateContext: class {
    func gotoCheckState()
    func gotoPromptState()
    func gotoUpdateState()
    func gotoSaveState(status: KYSStatus)
    func gotoFinalState(result: KYSResult)
    func notify(event: KYSEvent)
    func getStatus(completion: @escaping (Result<KYSProfile, Error>) -> Void)
    func saveStatus(status: KYSStatus, completion: @escaping (Bool) -> Void)
}


private class AnyState: IState {
    weak var context: IStateContext?
    init(context: IStateContext) {
        self.context = context
    }
    func enter() {
    }
    func exit() {
    }
    func check() {
    }
    func update() {
    }
    func cancel() {
    }
    func save(status: KYSStatus) {
    }
}


private class CheckState: AnyState {
    override func enter() {
        context?.getStatus { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                switch result {
                case .failure(_):
                    self.context?.gotoFinalState(result: .failure)
                case .success(let profile):
                    switch profile.validity {
                    case .current:
                        self.context?.gotoFinalState(result: .upToDate)
                    case .outdated:
                        self.context?.gotoPromptState()
                    }
                }
            }
        }
    }
}


private class PromptState: AnyState {
    override func enter() {
        context?.notify(event: .prompt)
    }
    override func update() {
        context?.gotoUpdateState()
    }
    override func cancel() {
        context?.gotoFinalState(result: .userPostponed)
    }
}


private class UpdateState: AnyState {
    override func enter() {
        context?.notify(event: .update)
    }
    override func cancel() {
        context?.gotoFinalState(result: .userCancelled)
    }
    override func save(status: KYSStatus) {
        context?.gotoSaveState(status: status)
    }
}


private class SaveState: AnyState {
    private let status: KYSStatus
    init(status: KYSStatus, context: IStateContext) {
        self.status = status
        super.init(context: context)
    }
    override func enter() {
        context?.notify(event: .save)
        context?.saveStatus(status: status) { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                if success {
                    self.context?.gotoFinalState(result: .success)
                }
                else {
                    self.context?.gotoFinalState(result: .failure)
                }
            }
        }
    }
}


private class FinalState: AnyState {
    private let result: KYSResult
    init(result: KYSResult, context: IStateContext) {
        self.result = result
        super.init(context: context)
    }
    override func enter() {
        switch result {
        case .failure:
            context?.notify(event: .failed)
        case .success:
            context?.notify(event: .updated)
        case .upToDate:
            context?.notify(event: .upToDate)
        case .userPostponed:
            context?.notify(event: .postponed)
        case .userCancelled:
            context?.notify(event: .cancelled)
        }
    }
    override func check() {
        context?.gotoCheckState()
    }
}


public class KYSModel: IStateContext, IState {
    
    public typealias OnEvent = (KYSEvent) -> Void
    
    public var onEvent: OnEvent?
    
    private var currentState: AnyState?
    private let service: IKYSService
    
    init(service: IKYSService) {
        self.service = service
        gotoFinalState(result: .failure)
    }
    
    // IStateContext
    
    private func setState(_ state: AnyState) {
        currentState?.exit()
        currentState = state
        currentState?.enter()
    }
    
    internal func gotoCheckState() {
        setState(CheckState(context: self))
    }
    
    internal func gotoPromptState() {
        setState(PromptState(context: self))
    }
    
    internal func gotoUpdateState() {
        setState(UpdateState(context: self))
    }
    
    internal func gotoSaveState(status: KYSStatus) {
        setState(SaveState(status: status, context: self))
    }
    
    internal func gotoFinalState(result: KYSResult) {
        setState(FinalState(result: result, context: self))
    }
    
    internal func notify(event: KYSEvent) {
        onEvent?(event)
    }
    
    internal func getStatus(completion: @escaping (Result<KYSProfile, Error>) -> Void) {
        service.getStatus(completion: completion)
    }
    
    internal func saveStatus(status: KYSStatus, completion: @escaping (Bool) -> Void) {
        service.postStatus(status: status, completion: completion)
    }
    
    // IState
    
    public func check() {
        currentState?.check()
    }
    
    public func update() {
        currentState?.update()
    }

    public func save(status: KYSStatus) {
        currentState?.save(status: status)
    }
    
    public func cancel() {
        currentState?.cancel()
    }
}
