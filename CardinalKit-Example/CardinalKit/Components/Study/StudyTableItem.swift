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

enum StudyTableItem: Int {
    
    static var allValues: [StudyTableItem] {
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
    case survey, activeTask, coffee

    var task: ORKOrderedTask {
        switch self {
        case .survey:
            return StudyTasks.sf12Task
        case .activeTask:
            return StudyTasks.walkingTask
        case .coffee:
            return StudyTasks.coffeeTask
        //case .coffee
        }
    }

    var title: String {
        switch self {
        case .survey:
            return "Breathe"
        case .activeTask:
            return "6 Minute Walk Test"
        //hjsong
        case .coffee:
            return "Pain"
            
        }
    }

    var subtitle: String {
        switch self {
        case .survey:
            return "Repeat 10 times"
        case .activeTask:
            return "Perform a 6-minute walk."
         //hjsong
        case .coffee:
            return "Lower Back"
        }
    }

    var image: UIImage? {
        switch self {
        case .survey:
            return UIImage(named: "SurveyIcon")
            
        case .coffee: //hjsong
            return UIImage(named: "CoffeeIcon")
        default:
            return UIImage(named: "ActivityIcon")
        }
        
    }
    
     //hjsong
     var statusCommand : String {
        switch self {
        case .activeTask, .survey, .coffee:
            return ("Start")
            //return (UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21)))

                }
      }
            

    
//    case coffee
//
//    var task: ORKOrderedTask {
//        switch self {
//        case .coffee:
//            return StudyTasks.coffeeTask
//        }
//    }
//
//    var title: String {
//        switch self {
//        case .coffee:
//            return "Coffee Task"
//        }
//    }
//
//    var subtitle: String {
//        switch self {
//        case .coffee:
//            return "Record your coffee intake for the day."
//        }
//    }
//
//    var image: UIImage? {
//        switch self {
//        case .coffee:
//            return UIImage(named: "CoffeeIcon")
//        }
//    }
}
