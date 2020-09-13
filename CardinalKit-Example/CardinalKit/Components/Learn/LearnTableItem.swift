//
//  StudyTableItem.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit

import SwiftUI
//hjsong

enum LearnTableItem: Int {
    
    static var allValues: [LearnTableItem] {
        var index = 0
        return Array (
            AnyIterator {
                let returnedElement = self.init(rawValue: index)
                index = index + 1
                return returnedElement
            }
        )
    }

    // table items
    case about, participate, role, pain, videos

    var page: Int {
        switch self {
        case .about:
            return 1
        case .participate:
            return 2
        case .role:
            return 3
        case .pain:
            return 4
        case .videos:
            return 5
        }
    }

    var title: String {
        switch self {
        case .about:
            return "About This Study"
        case .participate:
            return "Who Can Participate?"
        case .role:
            return "Your Role"
        case .pain:
            return "What is Back Pain?"
        case .videos:
            return "KnowYourBack Videos"
        }
    }

    var image: UIImage? {
        switch self {
        case .about:
            return UIImage(named: "ActivityIcon")
        case .participate:
            return UIImage(named: "ActivityIcon")
        case .role:
            return UIImage(named: "ActivityIcon")
        case .pain:
            return UIImage(named: "ActivityIcon")
        case .videos:
            return UIImage(named: "ActivityIcon")
        }
    }
}
