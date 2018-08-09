//
//  YPAssetViewContainer.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 15/11/2016.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import UIKit
import Stevia
import AVFoundation

/// The container for asset (video or image). It containts the YPGridView and YPAssetZoomableView.
class YPAssetViewContainer: UIView {
    public var zoomableView: YPAssetZoomableView?
    public let grid = YPGridView()
    public let curtain = UIView()
    public let spinnerView = UIView()
    public let squareCropButton = UIButton()
    public let multipleSelectionButton = UIButton()
    public var onlySquare = YPConfig.library.onlySquare
    public var isShown = true
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    private var shouldCropToSquare = false
    private var isMultipleSelection = false
    
    
    public let bottomView = UIView()
    public let cameraButton = UIButton()
    public let cameraCircle = UIView()
    public let useButton = UIButton.init(type: UIButtonType.system)
    public let countLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(grid)
        grid.frame = frame
        clipsToBounds = true
        
        for sv in subviews {
            if let cv = sv as? YPAssetZoomableView {
                zoomableView = cv
                zoomableView?.myDelegate = self
            }
        }
        
        grid.alpha = 0
        
        let touchDownGR = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(handleTouchDown))
        touchDownGR.minimumPressDuration = 0
        touchDownGR.delegate = self
        addGestureRecognizer(touchDownGR)
        
        // TODO: Add tap gesture to play/pause. Add double tap gesture to square/unsquare
        
        sv(
            spinnerView.sv(
                spinner
            ),
            curtain
        )
        
        spinner.centerInContainer()
        spinnerView.fillContainer()
        curtain.fillContainer()
        
        spinner.startAnimating()
        spinnerView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        curtain.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        curtain.alpha = 0
        
        if !onlySquare {
            // Crop Button
            squareCropButton.setImage(YPConfig.icons.cropIcon, for: .normal)
            sv(squareCropButton)
            squareCropButton.size(42)
            |-15-squareCropButton
            squareCropButton.Bottom == zoomableView!.Bottom - 15
        }
        
        // Multiple selection button
        sv(multipleSelectionButton)
        multipleSelectionButton.size(42)
        multipleSelectionButton-15-|
        multipleSelectionButton.setImage(YPConfig.icons.multipleSelectionOffIcon, for: .normal)
        multipleSelectionButton.Bottom == zoomableView!.Bottom - 15
        
        
        let color = UIColor(red: 48.0 / 255.0, green: 66.0 / 255.0, blue: 87.0 / 255.0, alpha: 0.8)
        
        let bottomHeight: CGFloat = 55
        let outerCircleHeight: CGFloat = 67
        sv(bottomView)
//        bottomView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        bottomView.Bottom == zoomableView!.Bottom - 25
        bottomView.height(bottomHeight)
        |bottomView|
        
        
        bottomView.sv(cameraCircle)
        cameraCircle.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        cameraCircle.layer.cornerRadius = outerCircleHeight/2
        cameraCircle.clipsToBounds = true
        |-13-cameraCircle
        cameraCircle.size(outerCircleHeight)
        cameraCircle.centerVertically()
        
        bottomView.sv(cameraButton)
        cameraButton.size(bottomHeight)
        cameraButton.CenterX == cameraCircle.CenterX
        cameraButton.CenterY == cameraCircle.CenterY
        cameraButton.setImage(YPConfig.icons.cameraImage, for: .normal)
        cameraButton.backgroundColor = color
        cameraButton.layer.cornerRadius = bottomHeight/2
        cameraButton.clipsToBounds = true
        
        
        let useCircle = UIView()
        bottomView.sv(useCircle)
        useCircle.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        useCircle.layer.cornerRadius = outerCircleHeight/2
        useCircle.clipsToBounds = true
        useCircle-13-|
        useCircle.size(outerCircleHeight)
        useCircle.centerVertically()
        
        
        bottomView.sv(useButton)
        useButton.size(bottomHeight)
        useButton.CenterX == useCircle.CenterX
        useButton.CenterY == useCircle.CenterY
        useButton.setTitle(YPConfig.wordings.add, for: .normal)
        useButton.setTitleColor(.white, for: .normal)
        useButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        useButton.backgroundColor = color
        useButton.layer.cornerRadius = bottomHeight/2
        useButton.clipsToBounds = true
        
        bottomView.sv(countLabel)
        countLabel.textAlignment = .center
        countLabel.size(bottomHeight)
        countLabel.CenterX == useCircle.CenterX
        countLabel.CenterY == useCircle.CenterY
        countLabel.font = UIFont.systemFont(ofSize: 20)
        countLabel.textColor = .white
        countLabel.backgroundColor = color
        countLabel.layer.cornerRadius = bottomHeight/2
        countLabel.clipsToBounds = true
        countLabel.isHidden = true
        
        bottomView.isHidden = !YPConfig.library.allowMultipleItems
    }
    
    func showUseButton() {
        countLabel.isHidden = true
        useButton.isHidden = false
    }
    
    // MARK: - Square button

    @objc public func squareCropButtonTapped() {
        if let zoomableView = zoomableView {
            let z = zoomableView.zoomScale
            if z >= 1 && z < zoomableView.squaredZoomScale {
                shouldCropToSquare = true
            } else {
                shouldCropToSquare = false
            }
        }
        zoomableView?.fitImage(shouldCropToSquare, animated: true)
    }
    
    public func refreshSquareCropButton() {
        if onlySquare {
            squareCropButton.isHidden = true
        } else {
            if let image = zoomableView?.assetImageView.image {
                let isImageASquare = image.size.width == image.size.height
                squareCropButton.isHidden = isImageASquare
            }
        }
    }
    
    // MARK: - Multiple selection

    /// Use this to update the multiple selection mode UI state for the YPAssetViewContainer
    public func setMultipleSelectionMode(on: Bool) {
        isMultipleSelection = on
        let image = on ? YPConfig.icons.multipleSelectionOnIcon : YPConfig.icons.multipleSelectionOffIcon
        multipleSelectionButton.setImage(image, for: .normal)
        refreshSquareCropButton()
    }
}

// MARK: - ZoomableViewDelegate
extension YPAssetViewContainer: YPAssetZoomableViewDelegate {
    public func ypAssetZoomableViewDidLayoutSubviews(_ zoomableView: YPAssetZoomableView) {
        let newFrame = zoomableView.assetImageView.convert(zoomableView.assetImageView.bounds, to: self)
        
        // update grid position
        grid.frame = frame.intersection(newFrame)
        grid.layoutIfNeeded()
        
        // Update play imageView position - bringing the playImageView from the videoView to assetViewContainer,
        // but the controll for appearing it still in videoView.
        if zoomableView.videoView.playImageView.isDescendant(of: self) == false {
            self.addSubview(zoomableView.videoView.playImageView)
            zoomableView.videoView.playImageView.centerInContainer()
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidZoom() {
        if isShown {
            UIView.animate(withDuration: 0.1) {
                self.grid.alpha = 1
            }
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidEndZooming() {
        UIView.animate(withDuration: 0.3) {
            self.grid.alpha = 0
        }
    }
}

// MARK: - Gesture recognizer Delegate
extension YPAssetViewContainer: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIButton)
    }
    
    @objc
    private func handleTouchDown(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if isShown {
                UIView.animate(withDuration: 0.1) {
                    self.grid.alpha = 1
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.3) {
                self.grid.alpha = 0
            }
        default: ()
        }
    }
}
