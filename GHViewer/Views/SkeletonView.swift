//
//  SkeletonView.swift
//  GHViewer
//
//  Created by Admin on 26/05/25.
//

import Foundation
import UIKit

class SkeletonView: UIView {
    private var gradientLayer: CAGradientLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSkeleton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSkeleton()
    }
    
    private func setupSkeleton() {
        backgroundColor = UIColor.systemGray5
        layer.cornerRadius = 8
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray4.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
        
        startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func startAnimating() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0, 0.25]
        animation.toValue = [0.75, 1, 1]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    func stopAnimating() {
        gradientLayer.removeAllAnimations()
        removeFromSuperview()
    }
}
