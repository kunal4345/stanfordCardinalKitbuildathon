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
import CareKit
import CareKitStore

/* ToDo
enum CareStudyTableItem: Int {
    
    static var allValues: [CareStudyTableItem] {
        var index = 0
        return Array (
            AnyIterator {
                let returnedElement = self.init(rawValue: index)
                index = index + 1
                return returnedElement
            }
        )
    }
    
    case doxylamine, survey, nausea
    var careTask : String {
        switch self {
        case .doxylamine:
            return   extract task from CareStudyTasks.synchronizedStoreManager  // not sure if the task should be in TaskID (String) or OCKTask
            }
    
    }
}
*/

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
            return StudyTasks.sf12Task  // hjsong : details are defined in StudyTasks.swift
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
        
}
