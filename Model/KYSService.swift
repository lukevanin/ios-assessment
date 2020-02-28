//
//  KYSService.swift
//  HornetAssessment
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import Foundation


///
/// User's HIV status. Used to retrieve and set the status.
///
public enum KYSStatus {
    case positive
    case negative
}


///
/// Validity state of a KYS status. Describes whether the status is up to date, or needs to be updated. This could
/// be implemented as a simple boolean for this example.
///
public enum KYSValidity {
    case current
    case outdated
}


///
/// Model class describing a KYS status, and the validity of the status information (whether the status needs to
/// be updated or not).
///
public struct KYSProfile {
    let status: KYSStatus
    let validity: KYSValidity
}


///
/// Service for retrieving and updating the user's KYS status information.
/// The concrete implementation for this would typically be a web service. For the assessment, this interface is
/// implemented by a mock service that returns controlled data. See KYSModelTestCase for details.
///
protocol IKYSService {
    typealias GetStatusCompletion = (Result<KYSProfile, Error>) -> Void
    typealias PostStatusCompletion = (Bool) -> Void
    
    ///
    /// Retrieves current KYSProfile, calling the completion closure with the result. Returns the profile status
    /// information, or an error if there was a problem fetching the profile information.
    ///
    func getStatus(completion: @escaping GetStatusCompletion)
    
    ///
    /// Updates the KYS status. Returns a boolean flag indicating success (true), or failure (false).
    /// The boolean flag is used for simplicity for demonstrative purposes. A real application might return
    /// something more complicated, such as a result with the profile or error, similar to the getStatus method.
    ///
    func postStatus(status: KYSStatus, completion: @escaping PostStatusCompletion)
}
