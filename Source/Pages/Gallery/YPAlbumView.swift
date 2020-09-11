//
//  YPAlbumView.swift
//  YPImagePicker
//
//  Created by Sacha Durand Saint Omer on 20/07/2017.
//  Copyright © 2017 Yummypets. All rights reserved.
//

import UIKit
import Stevia

class YPAlbumView: UIView {
    
    let tableView = UITableView()
    let spinner = UIActivityIndicatorView(style: .gray)
    
    convenience init() {
        self.init(frame: .zero)
        
        sv(
            tableView,
            spinner
        )
        tableView.contentInset = UIEdgeInsets.init(top: 8, left: 0, bottom: 0, right: 0)
        // TableView needs to be the first subview for it to automatically adjust its content inset with the NavBar
        
        spinner.centerInContainer()
        tableView.fillContainer()
        
        backgroundColor = .ypSystemBackground
    }
}
