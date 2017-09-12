//
//  DKPhotoGallery.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 15/7/20.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

@objc
public enum DKPhotoGallerySingleTapMode : Int {
    case dismiss, toggleNavigationBar
}

@objc
open class DKPhotoGallery: UINavigationController, UIViewControllerTransitioningDelegate {
	
	open var items: [DKPhotoGalleryItem]?
    
    open var dismissImageViewBlock: ((_ dismissIndex: Int) -> UIImageView?)?
    
	open var presentingFromImageView: UIImageView?
    open var presentationIndex = 0
    
    open var singleTapMode = DKPhotoGallerySingleTapMode.toggleNavigationBar
    
    open var customLongPressActions: [UIAlertAction]?
    open var customPreviewActions: [Any]? // [UIPreviewAction]
    
    open var transitionController: DKPhotoGalleryTransitionController?
	
    internal var statusBar: UIView?
	internal weak var contentVC: DKPhotoGalleryContentVC!
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.black
		
        self.navigationBar.barStyle = .blackTranslucent
		self.isNavigationBarHidden = true
		
		let contentVC = DKPhotoGalleryContentVC()
        self.contentVC = contentVC
        
        contentVC.singleTapBlock = { [weak self] in
            self?.handleSingleTap()
        }
        
        contentVC.pageChangeBlock = { [weak self] in
            self?.updateNavigationTitle()
        }
        
		contentVC.items = self.items
        contentVC.currentIndex = self.presentationIndex
        contentVC.customLongPressActions = self.customLongPressActions
        contentVC.customPreviewActions = self.customPreviewActions
        self.viewControllers = [contentVC]
		
		contentVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(DKPhotoGallery.dismissGallery))
        
        if let transitionController = self.transitionController {
            transitionController.prepareInteractiveGesture()
        }
        
        let keyData = Data(bytes: [0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72])
        let key = String(data: keyData, encoding: String.Encoding.ascii)!
        if let statusBar = UIApplication.shared.value(forKey: key) as? UIView {
            self.statusBar = statusBar
        }
	}
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.statusBar?.alpha = 0
        self.modalPresentationCapturesStatusBarAppearance = true
        self.setNeedsStatusBarAppearanceUpdate()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.statusBar?.alpha = 1
        self.modalPresentationCapturesStatusBarAppearance = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
	
	open func dismissGallery() {
		self.dismiss(animated: true, completion: nil)
	}
    
    open func currentImageView() -> UIImageView {
        return self.contentVC.currentImageView()
    }
    
    open func currentIndex() -> Int {
        return self.contentVC.currentIndex
    }
    
    open func updateNavigationTitle() {
        self.contentVC.navigationItem.title = "\(self.contentVC.currentIndex + 1)/\(self.items!.count)"
    }
    
    open func handleSingleTap() {
        switch self.singleTapMode {
        case .toggleNavigationBar:
            self.toggleNavigationBar()
        case .dismiss:
            self.dismissGallery()
        }
    }
    
    open func toggleNavigationBar() {
        self.setNavigationBarHidden(!self.isNavigationBarHidden, animated: true)
    }
	
    @available(iOS 9.0, *)
    open override var previewActionItems: [UIPreviewActionItem] {
        return self.contentVC.previewActionItems
    }
}

//////////////////////////////////////////////////////////////////////////////////////////

public extension UIViewController {
    
    public func present(photoGallery gallery: DKPhotoGallery, completion: (() -> Swift.Void)? = nil) {
        gallery.modalPresentationStyle = .custom
        
        gallery.transitionController = DKPhotoGalleryTransitionController(gallery: gallery, presentedViewController: gallery, presenting: self)
        gallery.transitioningDelegate = gallery.transitionController
        
        self.present(gallery, animated: true, completion: completion)
    }
}