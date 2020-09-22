//
//  StudyTask_Care.swift
//  CardinalKit_Example
//
//  Created by Isabel HJ Song on 9/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import CareKit
import SwiftUI
import Firebase
import CareKitStore
import ResearchKit


extension OCKStore {

    // Adds tasks and contacts into the store
    func populateSampleData() {

       
        let thisMorning = Calendar.current.startOfDay(for: Date())
        let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: thisMorning)!
        let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: aFewDaysAgo)!
        let afterLunch = Calendar.current.date(byAdding: .hour, value: 14, to: aFewDaysAgo)!

        let schedule = OCKSchedule(composing: [
            OCKScheduleElement(start: beforeBreakfast, end: nil,
                               interval: DateComponents(day: 1)),

            OCKScheduleElement(start: afterLunch, end: nil,
                               interval: DateComponents(day: 2))
        ])

        
        var doxylamine = OCKTask(id: "doxylamine", title: "Brace",
                                 carePlanUUID: nil, schedule: schedule)
        doxylamine.instructions = "Wear for as long as desired"


        let nauseaSchedule = OCKSchedule(composing: [OCKScheduleElement(start: beforeBreakfast, end: nil, interval: DateComponents(day: 2))])
        var nausea = OCKTask(id: "nausea", title: "Breathe",
                             carePlanUUID: nil, schedule: nauseaSchedule)
        nausea.impactsAdherence = false
        nausea.instructions = "\u{2022} Take a slow breath in through your nose, breathing into your lower belly (for about 4 seconds)."
        //\n\n\u{2022} Hold for 1 to 2 seconds.\n\n\u{2022}Exhale slowly through your mouth (for about 4 seconds).\n\n\u{2022} Wait a few seconds before taking another breath."

        
        let surveySchedule = OCKSchedule(composing: [OCKScheduleElement(start: beforeBreakfast, end: nil, interval: DateComponents(day: 2))])
        var survey=OCKTask(id: "survey", title: "Pain", carePlanUUID: nil, schedule: surveySchedule)
        survey.instructions = "Back Pain"
        

        addTasks([nausea, doxylamine], callbackQueue: .main, completion: nil)
        addTasks([survey], callbackQueue: .main, completion: nil)

  
}
}



