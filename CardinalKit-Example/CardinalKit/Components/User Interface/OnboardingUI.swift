//
//  OnboardingUI.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 8/14/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import UIKit
import ResearchKit
import CardinalKit
import Firebase

struct OnboardingElement {
    let logo: String
    let title: String
    let description: String
}

struct OnboardingUI: View {
    
    var onboardingElements: [OnboardingElement] = []
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    @State var showingDetail = false
    @State var showingStudyTasks = false
    
    init() {
        let onboardingData = config.readAny(query: "Onboarding") as! [[String:String]]
        
        
        self.color = Color(config.readColor(query: "Primary Color"))
        
        for data in onboardingData {
            self.onboardingElements.append(OnboardingElement(logo: data["Logo"]!, title: data["Title"]!, description: data["Description"]!))
        }
        
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if showingStudyTasks {
                StudiesUI()
            } else {
                Spacer()

                Text(config.read(query: "Team Name")).padding(.leading, 20).padding(.trailing, 20)
                Text(config.read(query: "Study Title"))
                 .foregroundColor(self.color)
                 .font(.system(size: 35, weight: .bold, design: .default)).padding(.leading, 20).padding(.trailing, 20)

                Spacer()

                PageView(self.onboardingElements.map { infoView(logo: $0.logo, title: $0.title, description: $0.description, color: self.color) })

                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        self.showingDetail.toggle()
                    }, label: {
                         Text("Join Study")
                            .padding(20).frame(maxWidth: .infinity)
                             .foregroundColor(.white).background(self.color)
                             .cornerRadius(15).font(.system(size: 20, weight: .bold, design: .default))
                    }).sheet(isPresented: $showingDetail, onDismiss: {
                         if let completed = UserDefaults.standard.object(forKey: "didCompleteOnboarding") {
                            self.showingStudyTasks = completed as! Bool
                         }
                    }, content: {
                        OnboardingVC()
                    })
                    Spacer()
                }
                
                Spacer()
            }
        }.onAppear(perform: {
            if let completed = UserDefaults.standard.object(forKey: "didCompleteOnboarding") {
                self.showingStudyTasks = completed as! Bool  //hjsong
                //self.showingStudyTasks = false //hjsong to always how on boarding
            }
        })
        
    }
}

struct OnboardingVC: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    typealias UIViewControllerType = ORKTaskViewController

    func makeUIViewController(context: Context) -> ORKTaskViewController {

        let config = CKPropertyReader(file: "CKConfiguration")
            
        
        /* **************************************************************
        * Step (0): User Eligibility
        **************************************************************/
        
        
//        let eligibilityTest = ORKInstructionStep(identifier: "eligibilityTest")
//               eligibilityTest.title = "Eligibility Test"
//               eligibilityTest.text = "Please answer these  questions honestly to make sure "
//
//
//               let booleanAnswer1 = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")
//               let textStep1 = ORKQuestionStep(identifier: "TextStep1", title: "Eligibility Test", question: "Are you 18 years old or older?", answer: booleanAnswer1)
//
        let eligProcessStep = makeEligibilityStep()

        
        /* **************************************************************
        *  STEP (1): get user consent
        **************************************************************/
        // use the `ORKVisualConsentStep` from ResearchKit
        
        //Ste
        
        
        let consentDocument = ConsentDocument()
        let consentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
        
        /* **************************************************************
        *  STEP (2): ask user to review and sign consent document
        **************************************************************/
        // use the `ORKConsentReviewStep` from ResearchKit
        let signature = consentDocument.signatures!.first!
        signature.title = "Patient"
        let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)
        reviewConsentStep.text = config.read(query: "Review Consent Step Text")
        reviewConsentStep.reasonForConsent = config.read(query: "Reason for Consent Text")
        
        /* **************************************************************
        *  STEP (3): get permission to collect HealthKit data
        **************************************************************/
        // see `HealthDataStep` to configure!
        let healthDataStep = CKHealthDataStep(identifier: "Health")
        
        /* **************************************************************
        *  STEP (4): ask user to enter their email address for login
        **************************************************************/
        // the `LoginStep` collects and email address, and
        // the `LoginCustomWaitStep` waits for email verification.
        
        let regexp = try! NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}")
        
        let registerStep = ORKRegistrationStep(identifier: "RegistrationStep", title: "Registration", text: "Sign up for this study.", passcodeValidationRegularExpression: regexp, passcodeInvalidMessage: "Your password does not meet the following criteria: minimum 8 characters with at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character", options: .init())
        
        let loginStep = ORKLoginStep(identifier: "LoginStep", title: "Login", text: "Log into this study.", loginViewControllerClass: LoginViewController.self)
    
        
//        let loginStep = PasswordlessLoginStep(identifier: PasswordlessLoginStep.identifier)
//        let loginVerificationStep = LoginCustomWaitStep(identifier: LoginCustomWaitStep.identifier)
        
        /* **************************************************************
        *  STEP (5): ask the user to create a security passcode
        *  that will be required to use this app!
        **************************************************************/
        // use the `ORKPasscodeStep` from ResearchKit.
        let passcodeStep = ORKPasscodeStep(identifier: "Passcode") //NOTE: requires NSFaceIDUsageDescription in info.plist
        let type = config.read(query: "Passcode Type")
        if type == "6" {
            passcodeStep.passcodeType = .type6Digit
        } else {
            passcodeStep.passcodeType = .type4Digit
        }
        passcodeStep.text = config.read(query: "Passcode Text")
        
        /* **************************************************************
        *  STEP (6): inform the user that they are done with sign-up!
        **************************************************************/
        // use the `ORKCompletionStep` from ResearchKit
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = config.read(query: "Completion Step Title")
        completionStep.text = config.read(query: "Completion Step Text")
        
        //hjsong
        /* **************************************************************
          *  STEP (7): start back screen tool!
          **************************************************************/
        
        let backScreenStep = ORKInstructionStep(identifier: "BackScreenStep")
        backScreenStep.title = "The Keele Start Back Screening Tool"
        backScreenStep.text = "Please answer these 9 questions to the best of your ability. It is OK to skip a question if you do not know the answer. Thinking about the last 2 weeks mark your responses to the following questions."
        

        let booleanAnswer = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")
        let textStep = ORKQuestionStep(identifier: "TextStep", title: "The Keele Start Back Screening Tool", question: "My back pain has spread down my leg(s) at some time in the last 2 weeks?", answer: booleanAnswer)
        
        
   
        /* hjsong
         let screenStep=
         let healthScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 5, minimumValue: 1, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "Excellent", minimumValueDescription: "Poor")
         let healthScaleQuestionStep = ORKQuestionStep(identifier: "HealthScaleQuestionStep", title: "Question #1", question: "In general, would you say your health is:", answer: healthScaleAnswerFormat)
         
         steps += [healthScaleQuestionStep]
         
        
         let formItem = ORKFormItem(identifier: "FormItem1", text: "MODERATE ACTIVITIES, such as moving a table, pushing a vacuum cleaner, bowling, or playing golf:", answerFormat: textChoiceAnswerFormat)
         let formItem2 = ORKFormItem(identifier: "FormItem2", text: "Climbing SEVERAL flights of stairs:", answerFormat: textChoiceAnswerFormat)
         let formStep = ORKFormStep(identifier: "FormStep", title: "Daily Activities", text: "The following two questions are about activities you might do during a typical day. Does YOUR HEALTH NOW LIMIT YOU in these activities? If so, how much?")
         formStep.formItems = [formItem, formItem2]
         
         steps += [formStep]
         
         let booleanAnswer = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")
         let booleanQuestionStep = ORKQuestionStep(identifier: "QuestionStep", title: nil, question: "In the past four weeks, did you feel limited in the kind of work that you can accomplish?", answer: booleanAnswer)
         
         steps += [booleanQuestionStep]
        */
        //hjsong
        
        /* **************************************************************
        * finally, CREATE an array with the steps to show the user
        **************************************************************/
        
        // given intro steps that the user should review and consent to
        let introSteps = [eligProcessStep,consentStep, reviewConsentStep]
        
        // and steps regarding login / security
        //let emailVerificationSteps = [registerStep, loginStep, passcodeStep, healthDataStep, completionStep] //hjsong
        let emailVerificationSteps = [registerStep, loginStep, passcodeStep, healthDataStep, completionStep, backScreenStep,textStep]
        
        // guide the user through ALL steps
        let fullSteps = introSteps + emailVerificationSteps
        
        // unless they have already gotten as far as to enter an email address
        var stepsToUse = fullSteps
        if CKStudyUser.shared.email != nil {
            stepsToUse = emailVerificationSteps
        }
        
        /* **************************************************************
        * and SHOW the user these steps!
        **************************************************************/
        // create a task with each step
        let orderedTask = ORKOrderedTask(identifier: "StudyOnboardingTask", steps: stepsToUse)
        
        // wrap that task on a view controller
        let taskViewController = ORKTaskViewController(task: orderedTask, taskRun: nil)
        taskViewController.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return taskViewController

    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

        }

    //Eligibility test function
    
    func makeEligibilityStep() -> ORKNavigablePageStep {
        let eligQues = "Please verify the following:\n\n\u{2022} You are at least 18 years old\n\n\u{2022} You reside in the US \n\n\u{2022} You can read and understand English in order to provide informed consent and follow this app's instructions"
        let eligTextChoices = [
            ORKTextChoice(text: "Yes, these are ALL true", value: 0 as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "No", value: 1 as NSCoding & NSCopying & NSObjectProtocol)
        ]
        let eligAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: eligTextChoices)
        let eligStep = ORKQuestionStep(identifier: "EligibilityQuestionStep",
                                       title: "Eligiblity",
                                       question: "Eligiblity",
                                       answer: eligAnswerFormat)
        eligStep.text = eligQues
        eligStep.isOptional = false
        
        // change both success and failure to be of type completion subclasssed
        let eligFailureStep = ORKInstructionStep(identifier:"EligibilityFailureStep")
        eligFailureStep.title = "Sorry"
        eligFailureStep.text = "You aren't eligible for this study."
        //eligFailureStep.image = UIImage.init(named: "13_RiskToPrivacy")
        
        let eligQues2 = "Please verify the following:\n\n\u{2022} You DO NOT have any serious chronic medical issues that may limit your ability to participate in physical therapy and home exercise or make participation in physical therapy and home exercise medically inadvisable. This includes cancer, severe arthritis, neuropathy or other neuromuscular disease, angina, cardiovascular disease, pulmonary disease, stroke or other neurological disorder, or peripheral vascular disease\n\n\u{2022} You ARE NOT pregnant, incarcerated, or decisionally impaired"
        
        let eligTextChoices2 = [
            ORKTextChoice(text: "Yes, these are ALL true", value: 0 as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "No", value: 1 as NSCoding & NSCopying & NSObjectProtocol)
        ]
        let eligAnswerFormat2 = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: eligTextChoices2)
        let eligStep2 = ORKQuestionStep(identifier: "EligibilityQuestionStep2",
                                        title: "Eligiblity",
                                        question: "Eligiblity",
                                        answer: eligAnswerFormat2)
        eligStep2.text = eligQues2
        eligStep2.isOptional = false
        
        let eligSuccessStep = ORKInstructionStep(identifier:"EligibilitySuccessStep")
        eligSuccessStep.text = "Great, you're eligible for the study!"
        eligSuccessStep.detailText = "Let's continue."
        
        let resultSelector = ORKResultSelector(stepIdentifier: "EligibilityQuestionStep", resultIdentifier: "EligibilityQuestionStep")
        let predicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: 0 as NSCoding & NSCopying & NSObjectProtocol)
        let eligPredicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [(predicate, "EligibilityQuestionStep2")])
        
        let resultSelector2 = ORKResultSelector(stepIdentifier: "EligibilityQuestionStep2", resultIdentifier: "EligibilityQuestionStep2")
        let predicate2 = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector2, expectedAnswerValue: 1 as NSCoding & NSCopying & NSObjectProtocol)
        let eligPredicateRule2 = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [(predicate2, "EligibilityFailureStep")])
        
        let eligProcessTask = ORKNavigableOrderedTask(identifier: "eligTask", steps: [eligStep, eligFailureStep, eligStep2, eligSuccessStep])
        eligProcessTask.setNavigationRule(eligPredicateRule, forTriggerStepIdentifier: "EligibilityQuestionStep")
        eligProcessTask.setNavigationRule(eligPredicateRule2, forTriggerStepIdentifier: "EligibilityQuestionStep2")
        eligProcessTask.setNavigationRule(ORKDirectStepNavigationRule(destinationStepIdentifier: "EligibilityQuestionStep"),
                                          forTriggerStepIdentifier: "EligibilityFailureStep")
        let eligProcessStep = ORKNavigablePageStep(identifier: "eligProcessStep", pageTask: eligProcessTask)
        eligProcessStep.title = "Eligiblity"
        return eligProcessStep
    }
    
    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            switch reason {
            case .completed:
                // if we completed the onboarding task view controller, go to study.
                // performSegue(withIdentifier: "unwindToStudy", sender: nil)
                
                // TODO: where to go next?
                // trigger "Studies UI"
                
                UserDefaults.standard.set(true, forKey: "didCompleteOnboarding")
                
                let signatureResult = taskViewController.result.stepResult(forStepIdentifier: "ConsentReviewStep")?.results?.first as! ORKConsentSignatureResult
                
                let consentDocument = ConsentDocument()
                signatureResult.apply(to: consentDocument)

                consentDocument.makePDF { (data, error) -> Void in
                    
                    let config = CKPropertyReader(file: "CKConfiguration")
                        
                    var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
                    docURL = docURL?.appendingPathComponent("\(config.read(query: "Consent File Name")).pdf") as NSURL?
                    

                    do {
                        let url = docURL! as URL
                        try data?.write(to: url)
                        
                        UserDefaults.standard.set(url.path, forKey: "consentFormURL")
                        print(url.path)

                    } catch let error {

                        print(error.localizedDescription)
                    }
                }
                
                
                print("Login successful! task: \(taskViewController.task?.identifier ?? "(no ID)")")
                
                fallthrough
            default:
                // otherwise dismiss onboarding without proceeding.
                taskViewController.dismiss(animated: true, completion: nil)
            }
        }
        
        func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
            
            // MARK: - Advanced Concepts
            // Sometimes we might want some custom logic
            // to run when a step appears 🎩
            
            if stepViewController.step?.identifier == PasswordlessLoginStep.identifier {
                
                /* **************************************************************
                * When the login step appears, asking for the patient's email
                **************************************************************/
                if let _ = CKStudyUser.shared.currentUser?.email {
                    // if we already have an email, go forward and continue.
                    DispatchQueue.main.async {
                        stepViewController.goForward()
                    }
                }
                
            } else if (stepViewController.step?.identifier == "RegistrationStep") {
                
                if let _ = CKStudyUser.shared.currentUser?.email {
                    // if we already have an email, go forward and continue.
                    DispatchQueue.main.async {
                        stepViewController.goForward()
                    }
                }
                
            } else if (stepViewController.step?.identifier == "LoginStep") {
                
                if let _ = CKStudyUser.shared.currentUser?.email {
                    // good — we have an email!
                } else {
                    let alert = UIAlertController(title: nil, message: "Creating account...", preferredStyle: .alert)

                    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                    loadingIndicator.hidesWhenStopped = true
                    loadingIndicator.style = UIActivityIndicatorView.Style.medium
                    loadingIndicator.startAnimating();

                    alert.view.addSubview(loadingIndicator)
                    taskViewController.present(alert, animated: true, completion: nil)
                    
                    let stepResult = taskViewController.result.stepResult(forStepIdentifier: "RegistrationStep")
                    if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer {
                        if let passwordRes = stepResult?.results?[1] as? ORKTextQuestionResult, let pass = passwordRes.textAnswer {
                            DispatchQueue.main.async {
                                Auth.auth().createUser(withEmail: email, password: pass) { (res, error) in
                                    DispatchQueue.main.async {
                                        if error != nil {
                                            alert.dismiss(animated: true, completion: nil)
                                            if let errCode = AuthErrorCode(rawValue: error!._code) {

                                                switch errCode {
                                                    default:
                                                        let alert = UIAlertController(title: "Registration Error!", message: error?.localizedDescription, preferredStyle: .alert)
                                                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

                                                        taskViewController.present(alert, animated: true)
                                                }
                                            }
                                            
                                            stepViewController.goBackward()

                                        } else {
                                            alert.dismiss(animated: true, completion: nil)
                                            print("Created user!")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else if (stepViewController.step?.identifier == "Passcode") {

                let alert = UIAlertController(title: nil, message: "Logging in...", preferredStyle: .alert)

                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.medium
                loadingIndicator.startAnimating();

                alert.view.addSubview(loadingIndicator)
                taskViewController.present(alert, animated: true, completion: nil)
                
                let stepResult = taskViewController.result.stepResult(forStepIdentifier: "LoginStep")
                if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer {
                    if let passwordRes = stepResult?.results?[1] as? ORKTextQuestionResult, let pass = passwordRes.textAnswer {
                        Auth.auth().signIn(withEmail: email, password: pass) { (res, error) in
                            DispatchQueue.main.async {
                                if error != nil {
                                    alert.dismiss(animated: true, completion: nil)
                                    if let errCode = AuthErrorCode(rawValue: error!._code) {

                                        switch errCode {
                                            default:
                                                let alert = UIAlertController(title: "Login Error!", message: error?.localizedDescription, preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

                                                taskViewController.present(alert, animated: true)
                                        }
                                    }
                                    
                                    stepViewController.goBackward()

                                } else {
                                    alert.dismiss(animated: true, completion: nil)
                                    print("successfully signed in!")
                                }
                            }
                        }
                    }
                }

                
            } else if stepViewController.step?.identifier == LoginCustomWaitStep.identifier {
                
                /* **************************************************************
                * When the email verification step appears, send email in background!
                **************************************************************/
                
                let stepResult = taskViewController.result.stepResult(forStepIdentifier: PasswordlessLoginStep.identifier)
                if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer {
                    
                    // if we received a valid email
                    CKStudyUser.shared.sendLoginLink(email: email) { (success) in
                        // send a login link
                        guard success else {
                            // and react accordingly if we ran into an error.
                            DispatchQueue.main.async {
                                let config = CKPropertyReader(file: "CKConfiguration")
                                
                                Alerts.showInfo(title: config.read(query: "Failed Login Title"), message: config.read(query: "Failed Login Text"))
                                stepViewController.goBackward()
                            }
                            return
                        }
                        
                        CKStudyUser.shared.email = email
                    }
                    
                }
                
            }
            
        }
        
        func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
            
            // MARK: - Advanced Concepts
            // Overriding the view controller of an ORKStep
            // lets us run our own code on top of what
            // ResearchKit already provides!
            
            if step is CKHealthDataStep {
                // this step lets us run custom logic to ask for
                // HealthKit permissins when this step appears on screen.
                return CKHealthDataStepViewController(step: step)
            }
            
            if step is LoginCustomWaitStep {
                // run custom code to send an email for login!
                return LoginCustomWaitStepViewController(step: step)
            }
            
            return nil
        }
    }
    
}

struct infoView: View {
    let logo: String
    let title: String
    let description: String
    let color: Color
    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 100, height: 100, alignment: .center)
                .padding(6).overlay(
                    Text(logo).foregroundColor(.white).font(.system(size: 42, weight: .light, design: .default))
                )

            Text(title).font(.title)
            
            Text(description).font(.body).multilineTextAlignment(.center).padding(.leading, 40).padding(.trailing, 40)
            
            
        }
    }
}

// PAGE VIEW CONTROLLER

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        let config = CKPropertyReader(file: "CKConfiguration")
        control.numberOfPages = numberOfPages
        control.pageIndicatorTintColor = UIColor.lightGray
        control.currentPageIndicatorTintColor = config.readColor(query: "Primary Color")
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)

        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }

    class Coordinator: NSObject {
        var control: PageControl

        init(_ control: PageControl) {
            self.control = control
        }
        @objc
        func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}

struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    @State var currentPage = 0
    init(_ views: [Page]) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
            PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
        }
    }
}

struct PageViewController: UIViewControllerRepresentable {
    var controllers: [UIViewController]
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers(
        [self.controllers[self.currentPage]], direction: .forward, animated: true)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController

        init(_ pageViewController: PageViewController) {
            self.parent = pageViewController
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return parent.controllers.last
            }
            return parent.controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == parent.controllers.count {
                return parent.controllers.first
            }
            return parent.controllers[index + 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
                let visibleViewController = pageViewController.viewControllers?.first,
                let index = parent.controllers.firstIndex(of: visibleViewController) {
                parent.currentPage = index
            }
        }
    }
}



struct OnboardingUI_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingUI()
    }
}
