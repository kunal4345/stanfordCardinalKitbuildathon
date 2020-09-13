import SwiftUI
import MessageUI
import CardinalKit
import ResearchKit
import Firebase
public var healthscale1 = 0
public var healthscale2 = 0

struct StudiesUI: View {
    
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    
    init() {
        self.color = Color(config.readColor(query: "Primary Color"))
    }
    
    var body: some View {
        TabView {
            ActivitiesView(color: self.color)
                .tabItem {
                    Image("tab_activities").renderingMode(.template)
                    Text("Activities")
            }
            
            InsightView(color: self.color)
                .tabItem{
                    Image("tab_dashboard").renderingMode(.template)
                    Text("Insights")
            }

            
            LearnView(color: self.color)
                .tabItem {
                    Image("tab_learn").renderingMode(.template)
                    Text("Learn")
            }
            
            ProfileView(color: self.color)
            .tabItem {
                Image("tab_profile").renderingMode(.template)
                Text("Profile")
            }
            
        }.accentColor(self.color)
    }
}

struct StudyItem: Identifiable {
    var id = UUID()
    let image: UIImage
    var title = ""
    var description = ""
    let task: ORKOrderedTask
    
    init(study: StudyTableItem) {
        self.image = study.image!
        self.title = study.title
        self.description = study.subtitle
        self.task = study.task
    }
}

struct ActivitiesView: View {
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    var date = ""
    var activities: [StudyItem] = []
    
    init(color: Color) {
        self.color = color
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, YYYY"
        
        self.date = formatter.string(from: date)
        
        let studyTableItems = StudyTableItem.allValues
        for study in studyTableItems {
            self.activities.append(StudyItem(study: study))
        }
    }
    
    var body: some View {
        VStack {
            Text(config.read(query: "Study Title")).font(.system(size: 25, weight:.bold)).foregroundColor(self.color)
            Text(config.read(query: "Team Name")).font(.system(size: 15, weight:.light))
            Text(self.date).font(.system(size: 18, weight: .regular)).padding()
            List {
                Section(header: Text("Current Activities")) {
                    
                    ForEach(0 ..< self.activities.count) {
                        ActivityView(icon: self.activities[$0].image, title: self.activities[$0].title, description: self.activities[$0].description, tasks: self.activities[$0].task)
                    }
                    
                }.listRowBackground(Color.white)
            }.listStyle(GroupedListStyle())
        }
    }
}

struct ActivityView: View {
    let icon: UIImage
    var title = ""
    var description = ""
    let tasks: ORKOrderedTask
    @State var showingDetail = false
    
    init(icon: UIImage, title: String, description: String, tasks: ORKOrderedTask) {
        self.icon = icon
        self.title = title
        self.description = description
        self.tasks = tasks
    }
    
    var body: some View {
        HStack {
            Image(uiImage: self.icon).resizable().frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text(self.title).font(.system(size: 18, weight: .semibold, design: .default))
                Text(self.description).font(.system(size: 14, weight: .light, design: .default))
            }
            Spacer()
            }.frame(height: 65).contentShape(Rectangle()).gesture(TapGesture().onEnded({
                self.showingDetail.toggle()
            })).sheet(isPresented: $showingDetail, onDismiss: {
                
            }, content: {
                TaskVC(tasks: self.tasks)
            })
    }
}

/* jle added LearnItem for menu options init */
struct LearnItem: Identifiable {
    var id = UUID()
    let image: UIImage
    var title = ""
    let page: Int
    
    init(learn: LearnTableItem) {
        self.image = learn.image!
        self.title = learn.title
        self.page = learn.page
    }
}

/* jle added the LearnView here */
struct LearnView: View {
    
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    var menuOptions = [LearnItem] () // Container for all menu options
  
    init(color: Color) {
        self.color = color
        
        let learnTableItems = LearnTableItem.allValues
        
        // Populate menuOptions array
        for menuOption in learnTableItems {
            self.menuOptions.append(LearnItem(learn: menuOption))
        }
    }
    
    var body: some View {
        VStack {
            Text("Learn")
                .font(.system(size: 25, weight: .bold))
                
            HStack {
                Image("StanfordMedicine")
            }
            VStack {
                Text("Thanks for participating in")
                    .foregroundColor(Color.gray)
                Text("Stanford Spinekeeper")
            }.padding(8)
            VStack {
                ForEach(0 ..< self.menuOptions.count) {
                    MenuOptionView(icon: self.menuOptions[$0].image, title: self.menuOptions[$0].title, page: self.menuOptions[$0].page)
                }.border(Color.gray)
            }
        }
    }
}

/* jle added the template view for a menu option */
struct MenuOptionView: View {
    let icon: UIImage
    var title = ""

    let page: Int
    @State var showingDetail = false
    
    init(icon: UIImage, title: String, page: Int) {
        self.icon = icon
        self.title = title
        self.page = page
    }
    
    
    var body: some View {
        HStack{
            Button(action: {
                self.showingDetail.toggle()
            }) {
               Image(uiImage: self.icon).resizable().frame(width: 32, height: 32)
               VStack(alignment: .leading) {
                   Text(self.title).font(.system(size: 18, weight: .semibold, design: .default))
               }
            }.sheet(isPresented: $showingDetail) {
                
                if(self.page == 1){
                    AboutView()
                }
                else if(self.page == 2){
                    ParticipateView()
                }
                else if (self.page == 3){
                    RoleView()
                }
                else if(self.page == 4) {
                    PainView()
                }
                else if(self.page == 5) {
                    VideosView()
                }
            }
        }
    }
}

struct AboutView: View{
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                Text("Welcome to the Stanford SpineKeeper Study!")
                Spacer()
                Text("We are asking you to join in a global study of spine health.Through your phone (or wearable band or smartwatch), we make it easy to \"donate\" data about your physical activity and sleep, and assess your fitness and risk factors, to better understand how to have a healthy back.")
                Spacer()
                Text("Being active every day has shown to help reduce back pain, and now we can measure activity in much more detail with smartphones and wearable devices. With your help, we can better our understanding of back pain and spine health. Combining your data with friends, family, and many others, you can help us determine how to keep our backs healthy over a long life.")
            }.padding(16)
        }
    }
}

struct ParticipateView: View{
    var body: some View {
        ScrollView {
            VStack {
                Text("All adults living in the United States are eligible. This study works most optimally with iPhone models 5s or higher, as these have special motion sensors built in that do not drain your battery. Finally, you need to be able to read and understand English. Versions in other languages and for more countries outside of the U.S. will be available in the future.")
            }.padding(16)
        }
    }
}

struct RoleView: View{
    var body: some View {
        ScrollView {
            VStack {
                Text("If you provide consent, you will be asked to allow the Stanford Spine Research app to collect health and activity data from your phone or wearable device, plus answer survey questions about any history of back pain disease and risk factors.")
                Spacer()
                Text("The app will ask you to complete a number of activities and surveys, and will also passively collect activity data. After the first day will take you less than 5 minutes to complete daily tasks. The Stanford Spine Research app will provide you feedback about how your activity and pain compare to others. You can continue to use the app for activity monitoring and tips for back pain exercises to try. The Stanford Spine Research app will also provide educational links to learn more about any of your data. You may also be asked to try different ways to help you improve your activity and back health.")
            }.padding(16)
        }
    }
}

struct PainView: View{
    var body: some View {
        ScrollView{
            VStack{
                Text("Key points about back pain:")
                Spacer()
                Text("\u{2022} Most back pain will go away within a few days or weeks.")
                Text("\u{2022} Back pain can occur anywhere in the spine, but is most common in the lower back or lumbar spine.")
                Text("\u{2022} Most back pain is not due to a serious illness.")
                Text("\u{2022} Back pain can be due to muscle strains, disc issues, trauma, arthritis, bone disease, aging and other causes.")
                Text("\u{2022} Many people who have back pain will have another episode of back pain within 2 years.")
                Text("\u{2022} Bedrest for too long is bad for your back pain - stay active!")
                //TODO: Retrieve links to these pages
            }.padding(16)
            VStack{
                Spacer()
                Text("Back Pain Information").foregroundColor(Color.blue)
                Text("Back Pain Coping Strategies").foregroundColor(Color.blue)
            }
        }
    }
}

struct VideosView: View{
    var body: some View {
        ScrollView {
            VStack {
                Text("Regular Exercises").border(Color.gray)
                Text("Smoking").border(Color.gray)
                Text("Maintaining a Healthy Weight").border(Color.gray)
                Text("Core Strength").border(Color.gray)
                Text("Body Mechanics").border(Color.gray)
                Text("Posture Tips").border(Color.gray)
                Text("Reduce Stress").border(Color.gray)
                Text("Strong Bones").border(Color.gray)
                Text("Weekend Warriors").border(Color.gray)
            }.padding(16)
        }
    }
}


// TODO: Complete Insight Page

    let db = Firestore.firestore()


public struct InsightView: View {
    let color: Color
    
    init(color: Color) {
        self.color = color
    }

   
//    db.collection("studies").getDocuments() { (querySnapshot, err) in
//        if let err = err {
//            print("Error getting documents: \(err)")
//        } else {
//            for document in querySnapshot!.documents {
//                print("\(document.documentID) => \(document.data())")
//            }
//        }
//    }
//
var days : [String] = ["M","T","W","T","F","S"]
//    let inthealthscale1 = Int(healthscale1)
//    let inthealthscale2 = Int(healthscale2)
//    let height = (inthealthscale1 * 10)
//    let height1 = (inthealthscale2 * 10)
    var cgfloat = CGFloat(healthscale1)
    var cgfloat1 = CGFloat(healthscale2)

  
    public var body: some View {
        ScrollView {
            VStack {
                HStack {
                    // TODO: Add row of numbers and circles
                    Text("13")
                    Text("14")
                    Text("15")
                    Text("16")
                    Text("17")
                    Text("18")
                    Text("19")
                }.border(Color.gray).frame(width: UIScreen.main.bounds.size.width)
                Text("Sep 13, 2020")
                
    // Card #1
    VStack{
                   VStack {
                       VStack {
                           Text("Back Pain").font(.headline)
                           Text("Level of Pain").font(.subheadline)
                       }.padding(15)
//                                       Spacer()
                    
                                HStack {
                                  // 2
                                    
                                    VStack {
                                             // 4
                                             Spacer()
                                             // 5
                                        HStack(alignment: .bottom){
                                             Rectangle()
                                               .fill(Color.green)
                                                .frame(width: 10, height: CGFloat(healthscale1) )
                                                Rectangle()
                                                  .fill(Color.green)
                                                    .frame(width: 10, height: CGFloat(healthscale2))
                                            
                                        }
                                             // 6
                                               Text("S")
                                               .font(.footnote)
                                               .frame(height: 20)
                                        
                                           }
                                  ForEach(0..<6) { temp in
                                    // 3
                                    VStack {
                                      // 4
                                      Spacer()
                                      // 5
                                      Rectangle()
                                        .fill(Color.green)
                                        .frame(width: 10, height: 01)
                                      // 6
                                        Text(self.days[temp])
                                        .font(.footnote)
                                        .frame(height: 20)
                                    }
                                  }
                    }

//                                       HStack {
//                                           VStack {
//                                               Text("S")
//                                               Text(healthscale1)
//                                               Text(healthscale2)
//
//                                           }
//                                           VStack {
//                                               Text("M")
//                                               Text("-")
//                                               Text("-")
//
//                                           }
//                                           VStack {
//                                               Text("T")
//                                               Text("-")
//                                               Text("-")
//                                           }
//                                           VStack {
//                                               Text("W")
//                                               Text("-")
//                                               Text("-")
//                                           }
//                                           VStack {
//                                               Text("T")
//                                               Text("-")
//                                               Text("-")
//                                           }
//                                           VStack {
//                                               Text("F")
//                                               Text("-")
//                                               Text("-")
//                                           }
//                                           VStack {
//                                               Text("S")
//                                               Text("-")
//                                               Text("-")
//                                           }
//                                       }
                       Spacer()
                   }
               }.frame(width: 250, height: 250, alignment: .center)
               .border(Color.gray)
               .padding(8)
    
                //card 2
                VStack{
                    VStack {
                        VStack {
                            Text("Six Minute Walk").font(.headline)
                            Text("Distance (in meters)").font(.subheadline)
                        }.padding(2)
                        
                        HStack {
                           // 2
                             
                             VStack {
                                      // 4
                                      Spacer()
                                      // 5
                                 HStack(alignment: .bottom){
                                      Rectangle()
                                        .fill(Color.green)
                                         .frame(width: 10, height: 30)
                                         
                                     
                                 }
                                      // 6
                                        Text("S")
                                        .font(.footnote)
                                        .frame(height: 20)
                                 
                                    }
                           ForEach(0..<6) { temp in
                             // 3
                             VStack {
                               // 4
                               Spacer()
                               // 5
                               Rectangle()
                                 .fill(Color.green)
                                 .frame(width: 10, height: 01)
                               // 6
                                 Text(self.days[temp])
                                 .font(.footnote)
                                 .frame(height: 20)
                             }
                           }
             }

                        
                        
//                        Spacer()
//                        HStack {
//                            VStack {
//                                Text("S")
//                                Text("8")
//                            }
//                            VStack {
//                                Text("M")
//                                Text("-")
//                            }
//                            VStack {
//                                Text("T")
//                                Text("-")
//                            }
//                            VStack {
//                                Text("W")
//                                Text("-")
//                            }
//                            VStack {
//                                Text("T")
//                                Text("-")
//                            }
//                            VStack {
//                                Text("F")
//                                Text("-")
//                            }
//                            VStack {
//                                Text("S")
//                                Text("-")
//                            }
//                        }
                        Spacer()
                    }
                }.frame(width: 250, height: 250, alignment: .center)
                .border(Color.gray)
                .padding(8)
                
                // Card #3
                VStack{
                    VStack {
                        VStack {
                            Text("Breathe").font(.headline)
                            Text("# of Times Completed").font(.subheadline)
                        }.padding(2)
                        
                        HStack {
                            VStack {
                                Spacer()
                                                                                         // 5
                                    HStack(alignment: .bottom){
                                         Rectangle()
                                           .fill(Color.green)
                                            .frame(width: 10, height: 50)
                                    }
                                         // 6
                                           Text("S")
                                           .font(.footnote)
                                           .frame(height: 20)
                                    }
                              ForEach(0..<6) { temp in
                                // 3
                                VStack {
                                  // 4
                                Spacer()
                                  // 5
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: 10, height: 01)
                                  // 6
                                    Text(self.days[temp])
                                    .font(.footnote)
                                    .frame(height: 20)
                                }
                              }
                }

                                               
                        
                        
//                        Spacer()
//                        HStack {
//                            VStack {
//                                Text("S")
//                                Text("6")
//                            }
//                            VStack {
//                                Text("M")
//                                Text("-")
//                            }
//                            VStack {
//                                Text("T")
//                                Text("-")
//                            }
//                            VStack {
//                                Text("W")
//                                Text("-")
//                            }
//                            VStack {
//                                Text("T")
//                                Text("-")
//                            }
//                            VStack {
//                                Text("F")
//                                Text("-")
//                            }
//                            VStack {
//                                Text("S")
//                                Text("-")
//                            }
//                        }
//                        Spacer()
                    }
                }.frame(width: 250, height: 250, alignment: .center)
                .border(Color.gray)
                .padding(8)
                
               
            }
        }
        //.frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
}

struct WithdrawView: View {
    let color: Color
    @State var showWithdraw = false
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text("Withdraw from Study").foregroundColor(self.color)
            Spacer()
            Text("›").foregroundColor(self.color)
        }.frame(height: 60)
            .contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
            self.showWithdraw.toggle()
            })).sheet(isPresented: $showWithdraw, onDismiss: {
                
            }, content: {
                WithdrawalVC()
            })
    }
}

struct ReportView: View {
    let color: Color
    var email = ""
    
    init(color: Color, email: String) {
        self.color = color
        self.email = email
    }
    
    var body: some View {
        HStack {
            Text("Report a Problem")
            Spacer()
            Text(self.email).foregroundColor(self.color)
        }.frame(height: 60).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
            EmailHelper.shared.sendEmail(subject: "App Support Request", body: "Enter your support request here.", to: self.email)
        }))
    }
}

struct SupportView: View {
    let color: Color
    var phone = ""
    
    init(color: Color, phone: String) {
        self.color = color
        self.phone = phone
    }
    
    var body: some View {
        HStack {
            Text("Support")
            Spacer()
            Text(self.phone).foregroundColor(self.color)
        }.frame(height: 60).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
            let telephone = "tel://"
                let formattedString = telephone + self.phone
            guard let url = URL(string: formattedString) else { return }
            UIApplication.shared.open(url)
        }))
    }
}

struct DocumentView: View {
    @State private var showPreview = false
    let documentsURL: URL!
    
    init() {
        let documentsPath = UserDefaults.standard.object(forKey: "consentFormURL")
        self.documentsURL = URL(fileURLWithPath: documentsPath as! String, isDirectory: false)
        print(self.documentsURL.path)
    }
    
    var body: some View {
        HStack {
            Text("View Consent Document")
            Spacer()
            Text("›")
        }.frame(height: 60).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
                self.showPreview = true
                
        })).background(DocumentPreview(self.$showPreview, url: self.documentsURL))
    }
}

struct HelpView: View {
    var site = ""
    
    init(site: String) {
        self.site = site
    }
    
    var body: some View {
        HStack {
            Text("Help")
            Spacer()
            Text("›")
        }.frame(height: 70).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
                if let url = URL(string: self.site) {
                UIApplication.shared.open(url)
            }
        }))
    }
}

struct ChangePasscodeView: View {
    @State var showPasscode = false
    
    var body: some View {
        HStack {
            Text("Change Passcode")
            Spacer()
            Text("›")
        }.frame(height: 70).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
                if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
                    self.showPasscode.toggle()
                }
        })).sheet(isPresented: $showPasscode, onDismiss: {
            
        }, content: {
            PasscodeVC()
        })
    }
}

struct PatientIDView: View {
    var userID = ""
    
    init() {
        if let currentUser = CKStudyUser.shared.currentUser {
           self.userID = currentUser.uid
       }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("PATIENT ID").font(.system(.headline)).foregroundColor(Color(.greyText()))
                Spacer()
            }
            HStack {
                Text(self.userID).font(.system(.body)).foregroundColor(Color(.greyText()))
                Spacer()
            }
        }.frame(height: 100)
    }
}

struct ProfileView: View {
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        VStack {
            Text("Profile").font(.system(size: 25, weight:.bold))
            List {
                Section {
                    PatientIDView()
                }.listRowBackground(Color.white)
                
                Section {
                    ChangePasscodeView()
                    HelpView(site: config.read(query: "Website"))
                }
                
                Section {
                    ReportView(color: self.color, email: config.read(query: "Email"))
                    SupportView(color: self.color, phone: config.read(query: "Phone"))
                    DocumentView()
                }
                
                Section {
                    WithdrawView(color: self.color)
                }
                
                Section {
                    Text(config.read(query: "Copyright"))
                }
            }.listStyle(GroupedListStyle())
        }
    }
}


struct StudiesUI_Previews: PreviewProvider {
    static var previews: some View {
        StudiesUI()
    }
}

public extension UIColor {
    class func greyText() -> UIColor {
        return UIColor(netHex: 0x989998)
    }
    
    class func lightWhite() -> UIColor {
        return UIColor(netHex: 0xf7f8f7)
    }
}

class EmailHelper: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailHelper()

    func sendEmail(subject:String, body:String, to:String){
        if !MFMailComposeViewController.canSendMail() {
            return
        }
        
        let picker = MFMailComposeViewController()
        
        picker.setSubject(subject)
        picker.setMessageBody(body, isHTML: true)
        picker.setToRecipients([to])
        picker.mailComposeDelegate = self
        
        EmailHelper.getRootViewController()?.present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        EmailHelper.getRootViewController()?.dismiss(animated: true, completion: nil)
    }
    
    static func getRootViewController() -> UIViewController? {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController
    }
}

struct DocumentPreview: UIViewControllerRepresentable {
    private var isActive: Binding<Bool>
    private let viewController = UIViewController()
    private let docController: UIDocumentInteractionController

    init(_ isActive: Binding<Bool>, url: URL) {
        self.isActive = isActive
        self.docController = UIDocumentInteractionController(url: url)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPreview>) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DocumentPreview>) {
        if self.isActive.wrappedValue && docController.delegate == nil { // to not show twice
            docController.delegate = context.coordinator
            self.docController.presentPreview(animated: true)
        }
    }

    func makeCoordinator() -> Coordintor {
        return Coordintor(owner: self)
    }

    final class Coordintor: NSObject, UIDocumentInteractionControllerDelegate { // works as delegate
        let owner: DocumentPreview
        init(owner: DocumentPreview) {
            self.owner = owner
        }
        func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            return owner.viewController
        }

        func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
            controller.delegate = nil // done, so unlink self
            owner.isActive.wrappedValue = false // notify external about done
        }
    }
}

struct PasscodeVC: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: ORKPasscodeViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    typealias UIViewControllerType = ORKPasscodeViewController

    func makeUIViewController(context: Context) -> ORKPasscodeViewController {

        let config = CKPropertyReader(file: "CKConfiguration")
        
        let num = config.read(query: "Passcode Type")
        
        if num == "4" {
            let editPasscodeViewController = ORKPasscodeViewController.passcodeEditingViewController(withText: "", delegate: context.coordinator, passcodeType:.type4Digit)
            
            return editPasscodeViewController
        } else {
            let editPasscodeViewController = ORKPasscodeViewController.passcodeEditingViewController(withText: "", delegate: context.coordinator, passcodeType: .type6Digit)
            
            return editPasscodeViewController
        }
        
    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

        }

    class Coordinator: NSObject, ORKPasscodeDelegate {
        func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
            viewController.dismiss(animated: true, completion: nil)
        }
        
        func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
            viewController.dismiss(animated: true, completion: nil)
        }
        

    }
    
}

struct TaskVC: UIViewControllerRepresentable {
    
    let vc: ORKTaskViewController
    
    init(tasks: ORKOrderedTask) {
        self.vc = ORKTaskViewController(task: tasks, taskRun: NSUUID() as UUID)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    typealias UIViewControllerType = ORKTaskViewController

    func makeUIViewController(context: Context) -> ORKTaskViewController {
        
        if vc.outputDirectory == nil {
            vc.outputDirectory = context.coordinator.CKGetTaskOutputDirectory(vc)
        }
        
        self.vc.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return self.vc

    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

        }

    public class Coordinator: NSObject, ORKTaskViewControllerDelegate {
       
        public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            switch reason {
            case .completed:
               do {
                    // (1) convert the result of the ResearchKit task into a JSON dictionary
                    if let json = try CKTaskResultAsJson(taskViewController.result) {
//                        print("****************************")
//                        print(json)
//                        print("=============================")
                        let x = String(describing: taskViewController.result.stepResult(forStepIdentifier: "HealthScaleQuestionStep1"))
                        let y = String(describing: taskViewController.result.stepResult(forStepIdentifier: "HealthScaleQuestionStep2"))
                        //print(x)
                        let numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                        let answer = "answer: "
                       

                        for i in numbers
                        {
                            
                            
                            var stringint = "\(i)"
                            var finalstring = answer + stringint
                            if x.contains(finalstring){
                             //   print(i)
                                healthscale1 = i * 10
                                break;
                            }
                            else{
                                print("not found")
                            }
                        }
                        
                        for j in numbers
                        {
                            
                            var stringint1 = "\(j)"
                            var finalstring1 = answer + stringint1
                            if y.contains(finalstring1){
                             //   print(i)
                                healthscale2 = j * 10
                                break;
                            }
                            else{
                                print("not found")
                            }
                        }
                        
                        print("##############################")
                        print(healthscale1)
                        print(healthscale2)
                        
                        
                       print("##############################")


//
//                       let db = Firestore.firestore()
//                        db.collection("studies").document("com.number.CardinalKit").collection("users")                                     .document("number")
//.setData(["number" : healthscale1, "number2" : healthscale2]) { err in
//                                        if let err = err {
//                                            print("Error writing document: \(err)")
//                                        } else {
//                                            // TODO: better configurable feedback via something like:
//                                            // https://github.com/Daltron/NotificationBanner
//                                            print("Document successfully written!")
//                    //                       print("HEREEEEEEEEE")
//                    //                        print(dataPayload.compactMapValues { $0 })
//                    //                        self.CKGetJSON()
//
//                                        }
//                                    }
//                        print("****************************")
//
//                        print(taskViewController.result.stepResult(forStepIdentifier: "HealthScaleQuestionStep2") )

//                        print(json)
                        print("****************************")

                        // (2) send using Firebase
                        try CKSendJSON(json)
                        
                        // (3) if we have any files, send those using Google Storage
                        if let associatedFiles = taskViewController.outputDirectory {
                            try CKSendFiles(associatedFiles, result: json)
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                fallthrough
            default:
                taskViewController.dismiss(animated: true, completion: nil)
                
            }
        
        }
        
        /**
        Create an output directory for a given task.
        You may move this directory.
         
         - Returns: URL with directory location
        */
        func CKGetTaskOutputDirectory(_ taskViewController: ORKTaskViewController) -> URL? {
            do {
                let defaultFileManager = FileManager.default
                
                // Identify the documents directory.
                let documentsDirectory = try defaultFileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                
                // Create a directory based on the `taskRunUUID` to store output from the task.
                let outputDirectory = documentsDirectory.appendingPathComponent(taskViewController.taskRunUUID.uuidString)
                try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
                
                return outputDirectory
            }
            catch let error as NSError {
                print("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
            }
            
            return nil
        }
        
        /**
         Parse a result from a ResearchKit task and convert to a dictionary.
         JSON-friendly.
         - Parameters:
            - result: original `ORKTaskResult`
         - Returns: [String:Any] dictionary with ResearchKit `ORKTaskResult`
        */
        func CKTaskResultAsJson(_ result: ORKTaskResult) throws -> [String:Any]? {
            let jsonData = try ORKESerializer.jsonData(for: result)
            return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
        }
        
        /**
         Given a JSON dictionary, use the Firebase SDK to store it in Firestore.
        */
        func CKSendJSON(_ json: [String:Any]) throws {
            
            if  let identifier = json["identifier"] as? String,
                let taskUUID = json["taskRunUUID"] as? String,
                let authCollection = CKStudyUser.shared.authCollection,
                let userId = CKStudyUser.shared.currentUser?.uid {
                
                let dataPayload: [String:Any] = ["userId":"\(userId)", "payload":json]
                
                // If using the CardinalKit GCP instance, the authCollection
                // represents the directory that you MUST write to in order to
                // verify and access this data in the future.
                
                let db = Firestore.firestore()
                db.collection(authCollection + "\(Constants.dataBucketSurveys)").document(identifier + "-" + taskUUID).setData(dataPayload) { err in
                    
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        // TODO: better configurable feedback via something like:
                        // https://github.com/Daltron/NotificationBanner
                        print("Document successfully written!")
//                       print("HEREEEEEEEEE")
//                        print(dataPayload.compactMapValues { $0 })
//                        self.CKGetJSON()

                    }
                }
                
            }
        }
        
        
        
      
    
        
//       func CKGetJSON()  {
//                   let db = Firestore.firestore()
//               let docRef = db.collection("studies").document("com.Kunal.CardinalKit").collection("users").document("GdKC73SAz6MHL7DrVeve1UMcA902").collection("surveys")
//
//                   docRef.getDocuments { (querySnapshot, err) in
//                        if let err = err {
//                                  print("Error getting documents: \(err)")
//                              } else {
//                                  for document in querySnapshot!.documents {
//                                      print("\(document.documentID) => \(document.data())")
//                                  }
//                              }
//                   }
//
//           }
        /**
         Given a file, use the Firebase SDK to store it in Google Storage.
        */
        func CKSendFiles(_ files: URL, result: [String:Any]) throws {
            if  let identifier = result["identifier"] as? String,
                let taskUUID = result["taskRunUUID"] as? String,
                let stanfordRITBucket = CKStudyUser.shared.authCollection {
                
                let fileManager = FileManager.default
                let fileURLs = try fileManager.contentsOfDirectory(at: files, includingPropertiesForKeys: nil)
                
                for file in fileURLs {
                    
                    var isDir : ObjCBool = false
                    guard FileManager.default.fileExists(atPath: file.path, isDirectory:&isDir) else {
                        continue //no file exists
                    }
                    
                    if isDir.boolValue {
                        try CKSendFiles(file, result: result) //cannot send a directory, recursively iterate into it
                        continue
                    }
                    
                    let storageRef = Storage.storage().reference()
                    let ref = storageRef.child("\(stanfordRITBucket)\(Constants.dataBucketStorage)/\(identifier)/\(taskUUID)/\(file.lastPathComponent)")
                    
                    let uploadTask = ref.putFile(from: file, metadata: nil)
                    
                    uploadTask.observe(.success) { snapshot in
                        // TODO: better configurable feedback via something like:
                        // https://github.com/Daltron/NotificationBanner
                        print("File uploaded successfully!")
                    }
                    
                    uploadTask.observe(.failure) { snapshot in
                        print("Error uploading file!")
                        /*if let error = snapshot.error as NSError? {
                            switch (StorageErrorCode(rawValue: error.code)!) {
                            case .objectNotFound:
                                // File doesn't exist
                                break
                            case .unauthorized:
                                // User doesn't have permission to access file
                                break
                            case .cancelled:
                                // User canceled the upload
                                break
                                
                                /* ... */
                                
                            case .unknown:
                                // Unknown error occurred, inspect the server response
                                break
                            default:
                                // A separate error occurred. This is a good place to retry the upload.
                                break
                            }
                        }*/
                    }
                    
                }
            }
        }

        
       
        
        
    }
    
}




struct WithdrawalVC: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    typealias UIViewControllerType = ORKTaskViewController

    func makeUIViewController(context: Context) -> ORKTaskViewController {

        let config = CKPropertyReader(file: "CKConfiguration")
        
        let instructionStep = ORKInstructionStep(identifier: "WithdrawlInstruction")
        instructionStep.title = NSLocalizedString(config.read(query: "Withdrawal Instruction Title"), comment: "")
        instructionStep.text = NSLocalizedString(config.read(query: "Withdrawal Instruction Text"), comment: "")
        
        let completionStep = ORKCompletionStep(identifier: "Withdraw")
        completionStep.title = NSLocalizedString(config.read(query: "Withdraw Title"), comment: "")
        completionStep.text = NSLocalizedString(config.read(query: "Withdraw Text"), comment: "")
        
        let withdrawTask = ORKOrderedTask(identifier: "Withdraw", steps: [instructionStep, completionStep])
        
        // wrap that task on a view controller
        let taskViewController = ORKTaskViewController(task: withdrawTask, taskRun: nil)
        
        taskViewController.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return taskViewController

    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

        }

    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            switch reason {
            case .completed:
                UserDefaults.standard.set(false, forKey: "didCompleteOnboarding")
                
                do {
                    try Auth.auth().signOut()
                    
                    if (ORKPasscodeViewController.isPasscodeStoredInKeychain()) {
                        ORKPasscodeViewController.removePasscodeFromKeychain()
                    }
                    
                    taskViewController.dismiss(animated: true, completion: {
                        fatalError()
                    })
                    
                } catch {
                    print(error.localizedDescription)
                    Alerts.showInfo(title: "Error", message: error.localizedDescription)
                }
                
            default:
                
                // otherwise dismiss onboarding without proceeding.
                taskViewController.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
}

