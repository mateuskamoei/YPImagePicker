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
    public var itemOverlay: UIView?
    public let curtain = UIView()
    public let spinnerView = UIView()
    public let squareCropButton = UIButton()
    public let multipleSelectionButton = UIButton()
    public var onlySquare = YPConfig.library.onlySquare
    public var isShown = true
    
    private let spinner = UIActivityIndicatorView(style: .white)
    private var shouldCropToSquare = YPConfig.library.isSquareByDefault
    private var isMultipleSelection = false
    
    
    public let bottomView = UIView()
    public let cameraButton = UIButton()
    public let useButton = UIButton(type: UIButton.ButtonType.system)
    public let countLabel = UILabel()

    public var itemOverlayType = YPConfig.library.itemOverlayType
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        switch itemOverlayType {
        case .grid:
            itemOverlay = YPGridView()
        default:
            break
        }
        
        if let itemOverlay = itemOverlay {
            addSubview(itemOverlay)
            itemOverlay.frame = frame
            clipsToBounds = true
            
            itemOverlay.alpha = 0
        }
        
        for sv in subviews {
            if let cv = sv as? YPAssetZoomableView {
                zoomableView = cv
                zoomableView?.myDelegate = self
            }
        }
        
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
        spinnerView.backgroundColor = UIColor.ypLabel.withAlphaComponent(0.3)
        curtain.backgroundColor = UIColor.ypLabel.withAlphaComponent(0.7)
        curtain.alpha = 0
        
        if !onlySquare {
            // Crop Button
            squareCropButton.setImage(YPConfig.icons.cropIcon, for: .normal)
            sv(squareCropButton)
            squareCropButton.size(45)
            squareCropButton-15-|
            squareCropButton.Top == zoomableView!.Top + 15
        }
        
        // Multiple selection button
        sv(multipleSelectionButton)
        multipleSelectionButton.size(42)
        multipleSelectionButton-15-|
        multipleSelectionButton.setImage(YPConfig.icons.multipleSelectionOffIcon, for: .normal)
        multipleSelectionButton.Top == zoomableView!.Top + 15
        
        
        let color = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        
        let bottomHeight: CGFloat = 45
        let outerCircleHeight: CGFloat = 67
        sv(bottomView)
//        bottomView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        bottomView.Bottom == zoomableView!.Bottom - 25
        bottomView.height(bottomHeight)
        |bottomView|
        
        sv(cameraButton)
        cameraButton.size(bottomHeight)
        |-15-cameraButton
        cameraButton.Top == zoomableView!.Top + 15
        cameraButton.setImage(YPConfig.icons.cameraImage, for: .normal)
        cameraButton.clipsToBounds = true
        
        bottomView.sv(useButton)
        useButton.size(bottomHeight)
        useButton-15-|
        useButton.centerVertically()
        useButton.setTitle(YPConfig.wordings.add, for: .normal)
        useButton.setTitleColor(.white, for: .normal)
        useButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        useButton.backgroundColor = color
        useButton.layer.cornerRadius = bottomHeight/2
        useButton.clipsToBounds = true
        
        bottomView.sv(countLabel)
        countLabel.textAlignment = .center
        countLabel.size(bottomHeight)
        countLabel.CenterX == useButton.CenterX
        countLabel.CenterY == useButton.CenterY
        countLabel.font = UIFont.systemFont(ofSize: 17)
        countLabel.textColor = .white
        countLabel.backgroundColor = color
        countLabel.layer.cornerRadius = bottomHeight/2
        countLabel.clipsToBounds = true
        countLabel.isHidden = true
        
        bottomView.isHidden = !YPConfig.library.allowMultipleItems
    }
    
    func showUseButton(isHidden: Bool) {
        countLabel.isHidden = true
        useButton.isHidden = isHidden
    }
    
    // MARK: - Square button

    @objc public func squareCropButtonTapped() {
        if let zoomableView = zoomableView {
            let z = zoomableView.zoomScale
            shouldCropToSquare = (z >= 1 && z < zoomableView.squaredZoomScale)
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
        
        let shouldFit = YPConfig.library.onlySquare ? true : shouldCropToSquare
        zoomableView?.fitImage(shouldFit)
        zoomableView?.layoutSubviews()
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
        
        if let itemOverlay = itemOverlay {
            // update grid position
            itemOverlay.frame = frame.intersection(newFrame)
            itemOverlay.layoutIfNeeded()
        }
        
        // Update play imageView position - bringing the playImageView from the videoView to assetViewContainer,
        // but the controll for appearing it still in videoView.
        if zoomableView.videoView.playImageView.isDescendant(of: self) == false {
            self.addSubview(zoomableView.videoView.playImageView)
            zoomableView.videoView.playImageView.centerInContainer()
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidZoom() {
        guard let itemOverlay = itemOverlay else {
            return
        }
        if isShown {
            UIView.animate(withDuration: 0.1) {
                itemOverlay.alpha = 1
            }
        }
    }
    
    public func ypAssetZoomableViewScrollViewDidEndZooming() {
        guard let itemOverlay = itemOverlay else {
            return
        }
        UIView.animate(withDuration: 0.3) {
            itemOverlay.alpha = 0
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
        guard let itemOverlay = itemOverlay else {
            return
        }
        switch sender.state {
        case .began:
            if isShown {
                UIView.animate(withDuration: 0.1) {
                    itemOverlay.alpha = 1
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.3) {
                itemOverlay.alpha = 0
            }
        default: ()
        }
    }
}
