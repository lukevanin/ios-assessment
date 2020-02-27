//
//  KYSService.swift
//  HornetAssessment
//
//  Created by Luke Van In on 2020/02/27.
//  Copyright © 2020 hornet. All rights reserved.
//

import Foundation


public enum KYSValidity {
    case current
    case outdated
}


public struct KYSProfile {
    let status: KYSStatus
    let validity: KYSValidity
}


protocol IKYSService {
    typealias GetStatusCompletion = (Result<KYSProfile, Error>) -> Void
    typealias PostStatusCompletion = (Bool) -> Void
    func getStatus(completion: @escaping GetStatusCompletion)
    func postStatus(status: KYSStatus, completion: @escaping PostStatusCompletion)
}
