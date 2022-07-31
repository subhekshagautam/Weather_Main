//
//  FavoriteWeatherView.swift
//  Weather
//
//  Created by Vikash Parajuli on 31/7/2022.
//

import UIKit

class HeartButton: UIButton {

    private var isLiked = false
    
    private let unlikedImage = UIImage(named: "heart_empty")
    private let likedImage = UIImage(named: "heart_fill")
    
    private let unlikedScale: CGFloat = 0.7
    private let likedScale: CGFloat = 1.3
    
    init(){
        super.init(frame: .zero)
        setImage(unlikedImage, for: .normal)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setImage(unlikedImage, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setImage(unlikedImage, for: .normal)
    }
    
    public func flipLikedState(liked: Bool) {
        isLiked = liked
        animate()
    }
    
    private func animate() {
        UIView.animate(withDuration: 0.1, animations: {
            let newImage = self.isLiked ? self.likedImage : self.unlikedImage
            let newScale = self.isLiked ? self.likedScale : self.unlikedScale
            self.transform = self.transform.scaledBy(x: newScale, y: newScale)
            self.setImage(newImage, for: .normal)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform.identity
            })
        })
    }

}
