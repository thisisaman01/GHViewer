//
//  HapticService.swift
//  GHViewer
//
//  Created by Admin on 26/05/25.
//

import Foundation
import UIKit

class HapticService {
    static let shared = HapticService()
    private init() {}
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    func impact() {
        impactFeedback.impactOccurred()
    }
    
    func selection() {
        selectionFeedback.selectionChanged()
    }
    
    func success() {
        notificationFeedback.notificationOccurred(.success)
    }
    
    func error() {
        notificationFeedback.notificationOccurred(.error)
    }
}
