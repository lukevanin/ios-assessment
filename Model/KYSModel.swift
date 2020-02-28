//
//  KYSModel.swift
//  HornetAssessment
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import Foundation


///
/// Final result from the KYS interaction. Used internally by the model to pass information to the final state.
///
internal enum KYSResult {
    case upToDate
    case userPostponed
    case userCancelled
    case failure
    case success
}


///
/// Events dispatched by the model to the observer. The controller should observe the model and update the
/// view state to correspond to the model.
///
public enum KYSEvent {
    
    /// Checking user's status.
    case check
    
    /// User's status is up to date, and does not need to be updated. The app does not need to do anything
    /// immediately, and can call check() again sometime in the future to query the status again.
    case upToDate

    /// Prompt state. Prompt the user to update their status. The user can proceed to update their status or opt
    /// out.
    case prompt
    
    /// User elected not to update their status when prompted.
    case postponed
    
    /// Update state. Present a UI to allow the user to update their status. The user can save their new status,
    /// or cancel the process.
    case update

    /// User cancelled updating their status instead of saving it.
    case cancelled

    /// Save state. The user's status is being saved. This event will be followed later by an `updated` event if
    /// the status was saved successfully, or a `failed` event if the status could not be saved. The app should
    /// display an activity indicator until the next event.
    case save
    
    /// User's status was saved successfully. The app should display a success message.
    case updated
    
    /// An error occurred while fetching or saving the user's status. The app should display an error message
    /// and allow the user to retry the previous action.
    /// Note: A single error state is used here for simplicity. A real app might use an alternate means of
    /// conveying errors, e.g.
    ///     *   One event for each type of error, or
    ///     *   Include an error value on the failure enum, e.g. case failure(Error)
    case failed

    /// KYS interaction completed. The app can call check() again to begin the interaction again.
    case finished
}


///
/// Interface for a specific state for the finite state machine. The operations are delegated from the primary
/// context class to the current active instance.
///
protocol IState {
    ///
    /// Check the user's status. Called by the application to initiate the KYS update procedure.
    /// Events:
    ///     * upToDate: User's status is up to date. No further action needed.
    ///     * prompt: User's status is not up to date. Prompt the user to update their status.
    ///     * failed: An error occurred (probably while fetching the user's status).
    ///
    func check()
    
    ///
    /// Update the user's status. Called by the application when showing the KYS prompt, when the user elects
    /// to update their KYS status.
    /// Events:
    ///     * update: User elected to update their KYS status.
    ///
    func update()
    
    ///
    /// Cancel the KYS procedure. Called by the application when showing the prompt and the user elects not
    /// to update their status, or when showing the update screen and the user cancels instead of saving.
    /// Events:
    ///     * userPostponed: User elected not to update their KYS status when prompted.
    ///     * cancelled: User cancelled the process after electing to update their status.
    ///
    func cancel()
    
    ///
    /// Save the user's status, typically by sending the data to a backend API. Called when the user saves
    /// thier status.
    /// Events:
    ///     * failed: Error occurred while saving the KYS status.
    ///     * updated: KYS status saved successfully.
    ///
    func save(status: KYSStatus)
}


///
/// Interface of the primary context class that is used by the state implementations. Using an interface
/// decouples the state from the primary class, allowing state classes to be tested independently of the primary
/// context class.
///
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


///
/// Abstract state class. All states may, but are not necessarily required to. inherit from this class. The default
/// behaviour of this class is to do nothing for all actions. Each child class can override the available
/// methods to provide the required functionality for each specific state.
///
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


///
/// Check State
/// Fetches the user's KYS status, and transitions to the next appropriate state based on the result:
///     *   Failure: Transition to final state with the "failure" result.
///     *   Status up to date: Transition to final state with "up to date" result.
///     *   Status not up to date: Transition to the prompt state.
/// Allowed Actions:
///     None
/// Events:
///     None
///
private class CheckState: AnyState {
    override func enter() {
        context?.notify(event: .check)
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


///
/// Prompt State
/// User's KYS status is outdated. The app should prompt the user to update their status.
/// Allowed Actions:
///     *   Update: Transition to the update state, to allow the user to update their status.
///     *   Cancel: Opt out of updating the status and transition to the final state.
/// Events:
///     *   Prompt: Prompt state entered.
///
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


///
/// Update State
/// User has elected to update their KYS status. The app should present a UI that allows the user to save their
/// status, or cancel the process.
/// Allowed Actions:
///     *   Cancel: Cancel the update procedure without updating the user's KYS status, and transition to the final
///         state,
///     *   Save: Transition to the save state and save the user's status.
/// Events:
///     *   Update: Update state entered.
///
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


///
/// Save State.
/// User status is being saved. Transitions to the following states depending on the result of the save
/// operation:
///     *   Success: Transition to final state with success result
///     *   Failure: Transition to final state with failure.
/// Allowed actions:
///     None
/// Events:
///     *   Save: Save state entered
///
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


///
/// Final State
/// KYS update procedure is complete. The application should display a message to indicate success or failure
/// depending on the result of the process. The application can also restart the KYS process  by calling
/// `check()`.
/// Allowed Actions:
///     * check: Check if the user's KYS status is up to date, and prompt the user to update their status if needed.
/// Events:
///     *   Failed: Process failed due to an error.
///     *   Updated: KYS status was updated successfully.
///     *   UpToDate: KYS status is up to date.
///     *   UserPostponed: KYS status is not up to date, and the user opted not to update their status.
///     *   UserCancelled: KYS status is not up to date, and the user cancelled the process before updating their
///         status.
///
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


///
/// Models the "Know Your Status" interaction flow, where the user is prompted to update thier HIV status.
///
/// The application interacts with the model by calling the public methods (check, update, save, cancel).
/// The model publishes events which the application should observe and respond to by updating the view
/// state. See KYSEvent for a description of the events posted by the model, and the recommended behaviour
/// for the application.
///
/// Usage:
///   * Observe events by setting a callback on the `onEvent` method.
///   * Call  `check()` method to check the user's status. If the user's status is up to date, the `upToDate` event is
///     posted. If the user's status is outdated, the `prompt` event is posted and the app should display a UI to
///     prompt the user to update their status.
///  *  When showing the prompt UI, the user can choose to update their status or opt out for the moment. The
///     application should call `cancel` to `postpone` the update, or call `update()` to proceed to updating the
///     status.
///  *  When showing the status update screen, the user can save the updated status or cancel the update. The
///     application should call `save()` to save the status, or call `cancel()` to end the update process.
///
/// Usage example:
///     let model = KYSModel()
///     model.onEvent = { event in
///         switch event {
///             case .check:
///                 // Raised when calling `check()`.
///                 break
///             case .upToDate:
///                 // Raised after calling `check()` and the user's status does not need to be updated.
///                 // KYS status does not need to be updated.
///                 break
///             case .prompt:
///                 // Raised after calling `check()` and the user's KYS status needs to be updated.
///                 // Show a dialog or alert to prompt the user to update their status.
///                 // Call `update()` to proceed to updating the status.
///                 // Call `cancel()` to opt out.
///                 showPrompt()
///             case .postponed:
///                 // Raised after calling `cancel()` during the prompt state.
///                 // Dismiss the prompt.
///                 dismissPrompt()
///             case .update:
///                 // Raised after calling `update()` from the prompt state.
///                 // Show a dialog to allow the user to update their status.
///                 // Call `save(status:)` to store the status.
///                 // Call `cancel()` to discard the status update.
///                 dismissPrompt()
///                 showUpdate()
///             case .cancelled:
///                 // Raised after calling `cancel()` from the update state.
///                 // Dismiss the update screen.
///                 dismissUpdate()
///             case .save:
///                 // Raised after calling `save()` from the update state.
///                 // Status is being saved.
///                 dismissUpdate()
///             case .updated:
///                 // Raised during the save state when the KYS status is saved successfully.
///                 // Display a success message.
///                 showToast("KYS updated")
///             case .finished:
///                 // KYS interaction completed. The application can call `check()` again.
///             case .failed:
///                 // An error occurred. Raised during check state and save state.
///                 showToast("Something broke! Please try again.")
///         }
///     }
///
public class KYSModel: IStateContext, IState {
    
    public typealias OnEvent = (KYSEvent) -> Void
    
    public var onEvent: OnEvent?
    
    private var currentState: AnyState?
    private let service: IKYSService
    
    init(service: IKYSService) {
        self.service = service
        gotoFinalState(result: .failure)
    }
    
    // MARK: IStateContext
    
    ///
    /// Transition from the current state to a new state.
    ///
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
    
    ///
    /// Notify the observer of an event.
    ///
    internal func notify(event: KYSEvent) {
        onEvent?(event)
    }
    
    ///
    /// Fetch the KYS status information from the KYS service.
    ///
    internal func getStatus(completion: @escaping (Result<KYSProfile, Error>) -> Void) {
        service.getStatus(completion: completion)
    }
    
    ///
    /// Save the KYS status using the KYS service.
    ///
    internal func saveStatus(status: KYSStatus, completion: @escaping (Bool) -> Void) {
        service.postStatus(status: status, completion: completion)
    }
    
    // MARK: IState
    
    ///
    /// Check the user's current KYS validity. Calling this method while a KYS update procedure is active has
    /// no effect.
    ///
    public func check() {
        currentState?.check()
    }
    
    ///
    /// Opts in to update the KYS status. The application should call this method when the user opts in to
    /// update their status.
    ///
    public func update() {
        currentState?.update()
    }

    ///
    /// Save the user's KYS status. The application should call this method when the user saves their KYS
    /// status during the update state.
    ///
    public func save(status: KYSStatus) {
        currentState?.save(status: status)
    }
    
    ///
    /// Cancel the KYS update procedure. The application should call this method when the user cancels the
    /// prompt, or cancels the update instead of saving.
    ///
    public func cancel() {
        currentState?.cancel()
    }
}
