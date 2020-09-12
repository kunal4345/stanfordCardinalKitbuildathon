//
//  StudyTasks.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit

/**
 This file contains some sample `ResearchKit` tasks
 that you can modify and use throughout your project!
*/
struct StudyTasks {
    
    /**
     Active tasks created with short-hand constructors from `ORKOrderedTask`
    */
    static let tappingTask: ORKOrderedTask = {
        let intendedUseDescription = "Finger tapping is a universal way to communicate."
        
        return ORKOrderedTask.twoFingerTappingIntervalTask(withIdentifier: "TappingTask", intendedUseDescription: intendedUseDescription, duration: 10, handOptions: .both, options: ORKPredefinedTaskOption())
    }()
    
    static let walkingTask: ORKOrderedTask = {
        let intendedUseDescription = "Tests ability to walk"
        let sixMinIntendedUseDescription = "Tests ability to walk for 6 mins"
        
        //return ORKOrderedTask.shortWalk(withIdentifier: "ShortWalkTask", intendedUseDescription: intendedUseDescription, numberOfStepsPerLeg: 20, restDuration: 30, options: ORKPredefinedTaskOption())
        //return ORKOrderedTask.timedWalk (withIdentifier: "6 Min Walk Task",  intendedUseDescription:sixMinIntendedUseDescription, distanceInMeters : 6, timeLimit :6, turnAroundTimeLimit:6, includeAssistiveDeviceForm:false , options:ORKPredefinedTaskOption())
        
        return ORKOrderedTask.fitnessCheck (withIdentifier:"6 min WalkTask", intendedUseDescription:sixMinIntendedUseDescription, walkDuration: 20 , restDuration: 10 , options: ORKPredefinedTaskOption())
       
    }()
    
    /**
        Coffee Task Example for 9/2 Workshop
     */
    static let coffeeTask: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        // Instruction step
        let instructionStep = ORKInstructionStep(identifier: "IntroStep")
        instructionStep.title = "Patient Questionnaire"
        instructionStep.text = "This information will help your doctors keep track of how you feel and how well you are able to do your usual activities. If you are unsure about how to answer a question, please give the best answer you can and make a written comment beside your answer."
        
        steps += [instructionStep]
        
        // hjsong
        let healthScaleAnswerFormat1 = ORKAnswerFormat.scale(withMaximumValue: 10, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "Worst pain imaginable 😬", minimumValueDescription: "No pain 😴")
        let healthScaleQuestionStep1 = ORKQuestionStep(identifier: "HealthScaleQuestionStep1", title: "Pain", question: "What was your average pain in the last 24 hours?", answer: healthScaleAnswerFormat1) //hjsong
        steps += [healthScaleQuestionStep1]
        
        let healthScaleAnswerFormat2 = ORKAnswerFormat.scale(withMaximumValue: 10, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "Worst pain imaginable 😬", minimumValueDescription: "No pain 😴")
        let healthScaleQuestionStep2 = ORKQuestionStep(identifier: "HealthScaleQuestionStep2", title: "Pain", question: "What was your maximum pain in the last 24 hours?", answer: healthScaleAnswerFormat2) //hjsong
        steps += [healthScaleQuestionStep2]
        //hjsong
        
        //SUMMARY
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you for tracking pain."
        summaryStep.text = "We appreciate your time."
        
        steps += [summaryStep]
        
        return ORKOrderedTask(identifier: "SurveyTask-Coffee", steps: steps)
        
    }()
    
    /**
     Sample task created step-by-step!
    */
    static let sf12Task: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        //hjsong
        // Instruction step
        let instructionStep = ORKInstructionStep(identifier: "IntroStep")
        instructionStep.title = "Breathe"
        instructionStep.text = "Repeat 10 times"
        instructionStep.detailText = "\n\n* Take a slow breath in through your nose, breathing into your lower belly for about 4 seconds\n* Hold for 1 to 2 seconds\n *Exhale slowly through your mouth for about 4 seconds\n*Wait a few seconds before taking another breath"
        
        
        steps += [instructionStep]
        
        /* hjsong
        In general, would you say your health is:
        let healthScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 5, minimumValue: 1, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "Excellent", minimumValueDescription: "Poor")
        let healthScaleQuestionStep = ORKQuestionStep(identifier: "HealthScaleQuestionStep", title: "Question #1", question: "In general, would you say your health is:", answer: healthScaleAnswerFormat)
        
        steps += [healthScaleQuestionStep]
        
        let textChoices = [
            ORKTextChoice(text: "Yes, Limited A lot", value: 0 as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Yes, Limited A Little", value: 1 as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "No, Not Limited At All", value: 2 as NSCoding & NSCopying & NSObjectProtocol)
        ]
        let textChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
        let textStep = ORKQuestionStep(identifier: "TextStep", title: "Daily Activities", question: "MODERATE ACTIVITIES, such as moving a table, pushing a vacuum cleaner, bowling, or playing golf:", answer: textChoiceAnswerFormat)
        
        steps += [textStep]
        
       
        let formItem = ORKFormItem(identifier: "FormItem1", text: "MODERATE ACTIVITIES, such as moving a table, pushing a vacuum cleaner, bowling, or playing golf:", answerFormat: textChoiceAnswerFormat)
        let formItem2 = ORKFormItem(identifier: "FormItem2", text: "Climbing SEVERAL flights of stairs:", answerFormat: textChoiceAnswerFormat)
        let formStep = ORKFormStep(identifier: "FormStep", title: "Daily Activities", text: "The following two questions are about activities you might do during a typical day. Does YOUR HEALTH NOW LIMIT YOU in these activities? If so, how much?")
        formStep.formItems = [formItem, formItem2]
        
        steps += [formStep]
        
        let booleanAnswer = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")
        let booleanQuestionStep = ORKQuestionStep(identifier: "QuestionStep", title: nil, question: "In the past four weeks, did you feel limited in the kind of work that you can accomplish?", answer: booleanAnswer)
        
        steps += [booleanQuestionStep]
        
        //SUMMARY
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you."
        summaryStep.text = "We appreciate your time."
        
        steps += [summaryStep]
        */
        
        return ORKOrderedTask(identifier: "SurveyTask-SF12", steps: steps)
    }()
}
