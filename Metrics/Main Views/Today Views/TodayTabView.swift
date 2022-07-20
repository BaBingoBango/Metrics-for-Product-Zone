//
//  TodayTabView.swift
//  Metrics
//
//  Created by Ethan Marshall on 6/20/22.
//

import SwiftUI
import CloudKit
import CoreData

/// The Today view, which contains a summary of the day's transactions along with Daily Goals and the Sharing section.
struct TodayTabView: View {
    // MARK: View Variables
    #if os(iOS)
    /// The horizontal size class of the current app environment.
    ///
    /// It is only relevant in iOS and iPadOS, since macOS and tvOS feature a consistent layout experience.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    /// Whether or not the transaction adder view is being presented.
    @State var showingAdderView = false
    /// The complete list of the user's transactions, fetched from Core Data.
    @FetchRequest(entity: Transaction.entity(), sortDescriptors: []) var transactions: FetchedResults<Transaction>
    /// A `TransactionServices` object used to interact with all of the user's transactions.
    var data: TransactionServices {
        return TransactionServices(transactions.reversed().reversed())
    }
    /// A `TransactionServices` object used to interact with all of the user's transactions from the current day.
    var todayData: TransactionServices {
        return TransactionServices(data.today())
    }
    /// A date formatter which provides date strings suitable for the Today view UI's heading.
    var todayViewDateFormatter: DateFormatter {
        let answer = DateFormatter()
        answer.dateStyle = .full
        answer.timeStyle = .none
        return answer
    }
    /// The amount to horizontally pad the entire view by.
    var horizontalPadding = 0
    /// Whether or not this view has performed an initial Sharing fetch operation.
    @State var hasCheckedSharing = false
    /// The status of a Sharing fetch operation taking place via this view.
    @State var fetchStatus = CloudKitOperationStatus.notStarted
    
    // Daily Goals variables
    /// Whether or not the user's daily goals should show in the Today view.
    @AppStorage("showGoalsInTodayView") var showGoalsInTodayView = true
    /// In percent, the user's daily AppleCare+ goal.
    @AppStorage("appleCareGoal") var appleCareGoal = 60
    /// The users daily business lead goal.
    @AppStorage("businessLeadsGoal") var businessLeadsGoal = 2
    /// In percent, the user's daily connectivity goal.
    @AppStorage("connectivityGoal") var connectivityGoal = 75
    
    /// Whether or not the the Sharing section should show in the Today view.
    @AppStorage("showSharingInTodayView") var showSharingInTodayView = true
    @State var isLoadingSharing = true
    @State var sharingServices: [TransactionServices] = []
    @State var todaySharingServices: [TransactionServices] = []
    @Environment(\.managedObjectContext) private var viewContext
    
    /// Whether or not a Sharing detail view is being presented.
    @State var isShowingSharingDetail = false
    
    // MARK: View Body
    var body: some View {
//        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text(todayViewDateFormatter.string(from: Date()).uppercased())
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                        Spacer()
                    }
                    
                    Text("Good \(getGenericTimeDescription())!")
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .truncationMode(.middle)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, showGoalsInTodayView ? 0 : 15)

                    if showGoalsInTodayView {
                        HStack {
                            if horizontalSizeClass != .compact {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .hidden()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .hidden()
                            }
                            
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .hidden()

                            if todayData.appleCarePercent() < appleCareGoal {
                                ZStack {
                                    ProgressBar(progress: Double(todayData.appleCarePercent()) / 100.0, color: .red, lineWidth: 8.5, imageName: "")
                                    
                                    Image(systemName: "applelogo")
                                        .aspectRatio(contentMode: .fit)
                                        .font(.system(size: 32.5))
                                        .foregroundColor(.red)
                                }
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .foregroundColor(.green)
                                    .padding(2.5)
                            }
                            
                            if todayData.numBusinessLeads() < businessLeadsGoal {
                                ZStack {
                                    ProgressBar(progress: Double(todayData.numBusinessLeads()) / Double(businessLeadsGoal), color: Color("brown"), lineWidth: 8.5, imageName: "")
                                    
                                    Image(systemName: "briefcase.fill")
                                        .aspectRatio(contentMode: .fit)
                                        .font(.system(size: 27.5))
                                        .foregroundColor(Color("brown"))
                                }
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .foregroundColor(.green)
                                    .padding(2.5)
                            }
                            
                            if todayData.connectivityPercent() < connectivityGoal {
                                ZStack {
                                    ProgressBar(progress: Double(todayData.connectivityPercent()) / 100.0, color: .blue, lineWidth: 8.5, imageName: "")
                                    
                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                        .aspectRatio(contentMode: .fit)
                                        .font(.system(size: 30))
                                        .foregroundColor(.blue)
                                }
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .foregroundColor(.green)
                                    .padding(2.5)
                            }

                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .hidden()
                            
                            if horizontalSizeClass != .compact {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .hidden()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .hidden()
                            }
                        }
                        .padding(.bottom, 10)

                        Text("\(getDayOfWeekDescription()) \(getGoalProgressDescription())")
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding([.leading, .bottom, .trailing])
                        
                    }
                    
                    if horizontalSizeClass == .compact {
                        AppleCareSummaryView(todayData: todayData)
                        
                        HStack {
                            BusinessLeadsSummaryView(todayData: todayData)
                            
                            ConnectivitySummaryView(todayData: todayData)
                        }
                        .padding(.horizontal)
                    } else {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.gray)
                                .opacity(0.15)
                                .cornerRadius(20)
                            
                            VStack {
                                HStack {
                                    Image(systemName: "applelogo")
                                        .imageScale(.large)
                                        .foregroundColor(.red)
                                    
                                    Text("AppleCare+   | ")
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                    
                                    Text("\(todayData.appleCarePercent())%")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    ProgressBar(progress: Double(todayData.customAppleCarePercent("iPhone")) / 100, color: .red, lineWidth: 8.5, imageName: "iphone")
                                        .aspectRatio(1, contentMode: .fit)
                                    
                                    ProgressBar(progress: Double(todayData.customAppleCarePercent("iPad")) / 100, color: .red, lineWidth: 8.5, imageName: "ipad.landscape")
                                        .aspectRatio(1, contentMode: .fit)
                                    
                                    ProgressBar(progress: Double(todayData.customAppleCarePercent("Mac")) / 100, color: .red, lineWidth: 8.5, imageName: "desktopcomputer")
                                        .aspectRatio(1, contentMode: .fit)
                                    
                                    ProgressBar(progress: Double(todayData.customAppleCarePercent("Apple Watch")) / 100, color: .red, lineWidth: 8.5, imageName: "applewatch")
                                        .aspectRatio(1, contentMode: .fit)
                                    
                                    ProgressBar(progress: Double(todayData.customAppleCarePercent("Apple TV")) / 100, color: .red, lineWidth: 8.5, imageName: "appletv")
                                        .aspectRatio(1, contentMode: .fit)
                                    
                                    ProgressBar(progress: Double(todayData.customAppleCarePercent("Headphones")) / 100, color: .red, lineWidth: 8.5, imageName: "headphones")
                                        .aspectRatio(1, contentMode: .fit)
                                    
                                    ZStack {
                                        ProgressBar(progress: 0.0, color: Color("brown"), lineWidth: 8.5, imageName: "")
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        VStack {
                                            Text("\(todayData.numBusinessLeads())")
                                                .font(.system(size: 30))
                                                .fontWeight(.bold)
                                                .foregroundColor(Color("brown"))
                                            
                                            Text(todayData.numBusinessLeads() != 1 ? "Leads" : "Lead")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color("brown"))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.1)
                                        }
                                    }
                                    
                                    ZStack {
                                        ProgressBar(progress: Double(todayData.connectivityPercent()) / 100, color: .blue, lineWidth: 8.5, imageName: "")
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        VStack {
                                            Text("\(todayData.connectivityPercent())%")
                                                .font(.body)
                                                .fontWeight(.bold)
                                                .foregroundColor(.blue)
                                            
                                            Text("Connect")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.blue)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.1)
                                        }
                                    }
                                }
                            }
                            .padding(.all)
                        }
                        .padding(.horizontal)
                    }
                    
                    if showSharingInTodayView {
                        HStack {
                            Text("Sharing")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if fetchStatus == .success || fetchStatus == .failure {
                                Button(action: {
                                    getSharingData()
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .aspectRatio(contentMode: .fit)
                                        .font(.system(size: 25))
                                        .foregroundColor(.accentColor)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding([.top, .leading])
                        
                        if fetchStatus == .inProgress {
                            HStack {
                                SharingRectangleView(isLoading: true)
                                
                                if UIDevice.current.userInterfaceIdiom != .phone {
                                    SharingRectangleView(isLoading: true)
                                        .hidden()
                                }
                            }
                                .padding(.horizontal)
                        } else if sharingServices.isEmpty {
                            HStack {
                                SharingRectangleView(isPlaceholder: true)
                                
                                if UIDevice.current.userInterfaceIdiom != .phone {
                                    SharingRectangleView(isPlaceholder: true)
                                        .hidden()
                                }
                            }
                                .padding(.horizontal)
                        } else {
                            ForEach(sharingServices, id: \.id) { eachData in
                                HStack {
                                    Button(action: {
                                        isShowingSharingDetail = true
                                    }) {
                                        SharingRectangleView(eachTodayData: {
                                            let todayTransactions = TransactionServices(eachData.today())
                                            todayTransactions.owner = eachData.owner
                                            return todayTransactions
                                        }())
                                    }
                                    .sheet(isPresented: $isShowingSharingDetail) {
                                        SharingTabView(transactions: eachData)
                                    }
                                    
                                    if sharingServices.last!.id == eachData.id && sharingServices.count % 2 != 0 && UIDevice.current.userInterfaceIdiom != .phone {
                                        SharingRectangleView(isPlaceholder: true)
                                            .hidden()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
            .onAppear {
                if !hasCheckedSharing {
                    getSharingData()
                    hasCheckedSharing = true
                }
            }
            
            // MARK: Navigation View Settings
            .navigationTitle(Text("Today"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAdderView.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .sheet(isPresented: $showingAdderView) {
                        AdderView()
                    }
                }
            }
//        }
    }
    
    // MARK: - View Functions
    /// Connects to the Internet to download Sharing data from the server.
    func getSharingData() {
        fetchStatus = .inProgress
        sharingServices = []
        todaySharingServices = []
        
        let zoneFetchOperation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        zoneFetchOperation.perRecordZoneResultBlock = { (recordZoneID: CKRecordZone.ID, recordZoneResult: Result<CKRecordZone, Error>) -> Void in
            switch recordZoneResult {
                
            case .success(let fetchedZone):
                var newTransactionSet: [Transaction] = []
                
                // Zone Operation 1: Transaction Query
                let queryOperation = CKQueryOperation(query: CKQuery(recordType: "CD_Transaction", predicate: NSPredicate(value: true)))
                queryOperation.zoneID = fetchedZone.zoneID
                
                queryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                    switch recordResult {
                        
                    case .success(let queriedRecord):
                        let transactionEntity = NSEntityDescription.entity(forEntityName: "Transaction", in: viewContext)!
                        let newTransaction = Transaction(entity: transactionEntity, insertInto: nil)
                        
                        newTransaction.id = UUID(uuidString: (queriedRecord.object(forKey: "CD_id") as? String)!)
                        newTransaction.date = queriedRecord.object(forKey: "CD_date") as? Date
                        newTransaction.deviceType = queriedRecord.object(forKey: "CD_deviceType") as? String
                        newTransaction.boughtAppleCare = queriedRecord.object(forKey: "CD_boughtAppleCare") as! Int == 1 ? true : false
                        newTransaction.connected = queriedRecord.object(forKey: "CD_connected") as! Int == 1 ? true : false
                        newTransaction.gotLead = queriedRecord.object(forKey: "CD_gotLead") as! Int == 1 ? true : false
                        newTransaction.isAppleCareStandalone = queriedRecord.object(forKey: "CD_isAppleCareStandalone") as! Int == 1 ? true : false
                        
                        newTransactionSet.append(newTransaction)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        fetchStatus = .failure
                    }
                }
                
                queryOperation.queryResultBlock = { (_ operationResult: Result<CKQueryOperation.Cursor?, Error>) -> Void in
                    // Zone Operation 2: Name Query
                    let nameOperation = CKQueryOperation(query: CKQuery(recordType: "cloudkit.share", predicate: NSPredicate(value: true)))
                    nameOperation.zoneID = fetchedZone.zoneID
                    nameOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                        switch recordResult {
                        case .success(let result):
                            if let shareRecord = result as? CKShare {
                                let newServices = TransactionServices(newTransactionSet)
                                newServices.owner = {
                                    let ownerFirstName = shareRecord.owner.userIdentity.nameComponents?.givenName
                                    let ownerLastName = shareRecord.owner.userIdentity.nameComponents?.familyName
                                    
                                    if ownerFirstName == nil {
                                        return "Name Not Provided"
                                    } else {
                                        if ownerLastName == nil {
                                            return ownerFirstName!
                                        } else {
                                            return ownerFirstName! + " " + ownerLastName!
                                        }
                                    }
                                }()
                                
                                sharingServices.append(newServices)
                                todaySharingServices.append(TransactionServices(newServices.today()))
                                
                                newTransactionSet = []
                                fetchStatus = .success
                            }
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            fetchStatus = .failure
                        }
                    }
                    CKContainer(identifier: "iCloud.Metrics").sharedCloudDatabase.add(nameOperation)
                }
                
                CKContainer(identifier: "iCloud.Metrics").sharedCloudDatabase.add(queryOperation)
                
            case .failure(let error):
                print(error.localizedDescription)
                fetchStatus = .failure
            }
        }
        
        zoneFetchOperation.fetchRecordZonesResultBlock = { (_ operationResult: Result<Void, Error>) -> Void in
            switch operationResult {
            case .success():
                print("Zone fetch success!")
                sleep(1)
                fetchStatus = .success
            case .failure(let error):
                print(error.localizedDescription)
                fetchStatus = .failure
            }
        }
        
        CKContainer(identifier: "iCloud.Metrics").sharedCloudDatabase.add(zoneFetchOperation)
    }
    /// Uses the current time to generate a generic word that describes the current part of the day.
    func getGenericTimeDescription() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let militaryTime = dateFormatter.string(from: Date())
        let hour = Int(militaryTime.components(separatedBy: ":")[0])!
        
        if hour >= 22 {
            // 9 PM - 11:59 PM
            return "evening"
        } else if hour >= 12 {
            // Noon - 9 PM
            return "afternoon"
        } else if hour >= 6 {
            // 6 AM - 11:59 AM
            return "morning"
        } else {
            // Midnight - 5:59 AM
            return "evening"
        }
    }
    /// Returns a short exclamatory string about the current day of the week.
    func getDayOfWeekDescription() -> String {
        if Date().dayOfWeek() == nil {
            return "Hello!"
        } else {
            switch Date().dayOfWeek()! {
            case "Monday":
                return [
//                    "Happy Monday!",
//                    "It's another week!",
                    "It's Monday..."
                ].randomElement()!
            case "Tuesday":
                return [
//                    "Happy Tuesday!",
                    "Happy 2's day!"
//                    "Happy not Monday!"
                ].randomElement()!
            case "Wednesday":
                return [
//                    "Happy Wednesday!",
                    "Happy hump day!"
//                    "Happy mid-week!"
                ].randomElement()!
            case "Thursday":
                return [
                    "Happy Thursday!"
//                    "It's Thursday almost Friday!"
                ].randomElement()!
            case "Friday":
                return [
//                    "Happy Friday!",
//                    "TGIF!",
                    "It's Friday!!"
                ].randomElement()!
            case "Saturday":
                return [
//                    "Happy Saturday!",
                    "Happy weekend!"
//                    "It's the weekend!"
                ].randomElement()!
            case "Sunday":
                return [
                    "Happy Sunday!"
//                    "Sunday funday!"
                ].randomElement()!
            default:
                return "Hello!"
            }
        }
    }
    /// Returns a string describing the user's progress on their Daily Goals.
    func getGoalProgressDescription() -> String {
        var goalsClear = 0
        if todayData.appleCarePercent() >= appleCareGoal { goalsClear += 1 }
        if todayData.numBusinessLeads() >= businessLeadsGoal { goalsClear += 1 }
        if todayData.connectivityPercent() >= connectivityGoal { goalsClear += 1 }
        
        switch goalsClear {
        case 0:
            return "It's a great time to get started on your goals! You can do it!"
        case 1:
            return "One down, two to go! Keep going, you got this!"
        case 2:
            return "You only have one goal to go! You're almost there!"
        case 3:
            return "All your goals are green right now! Great job, you did it!"
        default:
            return ""
        }
    }
}

// MARK: View Preview
struct TodayTabView_Previews: PreviewProvider {
    static var previews: some View {
        TodayTabView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

struct AppleCareSummaryView: View {
    
    var todayData: TransactionServices
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.gray)
                .opacity(0.15)
                .cornerRadius(20)
            
            VStack {
                HStack {
                    Image(systemName: "applelogo")
                        .imageScale(.large)
                        .foregroundColor(.red)
                    
                    Text("AppleCare+")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Spacer()
                    
                    Text("\(todayData.appleCarePercent())%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .padding([.top, .leading, .trailing])
                
                HStack(spacing: 0) {
                    
                    ProgressBar(progress: Double(todayData.customAppleCarePercent("iPhone")) / 100, color: .red, lineWidth: 8.5, imageName: "iphone")
                        .aspectRatio(1, contentMode: .fit)
                    
                    Spacer()
                    
                    ProgressBar(progress: Double(todayData.customAppleCarePercent("iPad")) / 100, color: .red, lineWidth: 8.5, imageName: "ipad.landscape")
                        .aspectRatio(1, contentMode: .fit)
                    
                    Spacer()
                    
                    ProgressBar(progress: Double(todayData.customAppleCarePercent("Mac")) / 100, color: .red, lineWidth: 8.5, imageName: "desktopcomputer")
                        .aspectRatio(1, contentMode: .fit)
                }
                .padding(.horizontal)
                
                HStack(spacing: 0) {
                    ProgressBar(progress: Double(todayData.customAppleCarePercent("Apple Watch")) / 100, color: .red, lineWidth: 8.5, imageName: "applewatch")
                        .aspectRatio(1, contentMode: .fit)
                    
                    Spacer()
                    
                    ProgressBar(progress: Double(todayData.customAppleCarePercent("Apple TV")) / 100, color: .red, lineWidth: 8.5, imageName: "appletv")
                        .aspectRatio(1, contentMode: .fit)
                    
                    Spacer()
                    
                    ProgressBar(progress: Double(todayData.customAppleCarePercent("Headphones")) / 100, color: .red, lineWidth: 8.5, imageName: "headphones")
                        .aspectRatio(1, contentMode: .fit)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
    }
}

struct BusinessLeadsSummaryView: View {
    
    var todayData: TransactionServices
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.gray)
                .opacity(0.15)
                .cornerRadius(20)
            
            HStack {
                VStack {
                    HStack(alignment: .center) {
                        Image(systemName: "briefcase.fill")
                            .imageScale(.large)
                            .foregroundColor(Color("brown"))
                        
                        Text("Leads")
                            .fontWeight(.bold)
                            .foregroundColor(Color("brown"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    }
                    .padding(.top)
                    .padding(.horizontal, 5)
                    
                    ZStack {
                        ProgressBar(progress: 0.0, color: Color("brown"), lineWidth: 8.5, imageName: "")
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text("\(todayData.numBusinessLeads())")
                            .font(.system(size: 30))
                            .fontWeight(.bold)
                            .foregroundColor(Color("brown"))
                    }
                    .padding(.bottom)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct ConnectivitySummaryView: View {
    
    var todayData: TransactionServices
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.gray)
                .opacity(0.15)
                .cornerRadius(20)
            
            HStack {
                VStack {
                    HStack(alignment: .center) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                        
                        Text("Connected")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    }
                    .padding(.top)
                    .padding(.horizontal, 5)
                    
                    ZStack {
                        ProgressBar(progress: Double(todayData.connectivityPercent()) / 100, color: .blue, lineWidth: 8.5, imageName: "")
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text("\(todayData.connectivityPercent())%")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
