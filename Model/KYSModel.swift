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
    case failed
    case finished
}


protocol IState {
    func check()
    func cancel()
    func save()
}


protocol IStateContext: class {
    func gotoCheckState()
    func gotoPromptState()
    func gotoUpdateState()
    func gotoSaveState()
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
    func cancel() {
    }
    func save() {
    }
    func update() {
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
}


private class UpdateState: AnyState {
    
}


private class SaveState: AnyState {
    
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
            context?.notify(event: .finished)
        case .upToDate:
            context?.notify(event: .finished)
        case .userPostponed:
            context?.notify(event: .finished)
        case .userCancelled:
            context?.notify(event: .finished)
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
    
    func gotoCheckState() {
        setState(CheckState(context: self))
    }
    
    func gotoPromptState() {
        setState(PromptState(context: self))
    }
    
    func gotoUpdateState() {
        setState(UpdateState(context: self))
    }
    
    func gotoSaveState() {
        setState(SaveState(context: self))
    }
    
    func gotoFinalState(result: KYSResult) {
        setState(FinalState(result: result, context: self))
    }
    
    func notify(event: KYSEvent) {
        onEvent?(event)
    }
    
    func getStatus(completion: @escaping (Result<KYSProfile, Error>) -> Void) {
        service.getStatus(completion: completion)
    }
    
    func saveStatus(status: KYSStatus, completion: @escaping (Bool) -> Void) {
        service.postStatus(status: status, completion: completion)
    }
    
    // IState
    
    public func check() {
        currentState?.check()
    }
    
    public func save() {
        currentState?.save()
    }
    
    public func cancel() {
        currentState?.cancel()
    }
}
