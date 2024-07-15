import SwiftUI
import Combine
import Zip
import Foundation

struct KYCData: Identifiable {
    var id: String // This is for Identifiable protocol
    var referenceId: String // New property for the reference ID
    var hashLayer: Int
    var name: String
    var dob: String
    var gender: String
    var email: String
    var mob: String
    var address: Address
    var encodedImage: String
    var aadharNum: String
}

struct Address {
    var careOf: String
    var country: String
    var district: String
    var house: String
    var landmark: String
    var locality: String
    var pincode: String
    var postOffice: String
    var state: String
    var street: String
    var subDistrict: String
    var vtc: String
}

class KYCParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var kycData: KYCData?
    private var address: Address?
    private var referenceId = ""

    func parse(data: Data) -> KYCData? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return kycData
    }

    // XMLParserDelegate methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "OfflinePaperlessKyc" {
            referenceId = attributeDict["referenceId"] ?? ""
        } else if elementName == "UidData" {
            kycData = KYCData(
                id: referenceId, // Use referenceId for the id property
                referenceId: referenceId,
                hashLayer: (Int(String(referenceId[referenceId.index(referenceId.startIndex, offsetBy: 3)])) == 0) ? 1 : (Int(String(referenceId[referenceId.index(referenceId.startIndex, offsetBy: 3)])) ?? 1),
                name: "",
                dob: "",
                gender: "",
                email: "",
                mob: "",
                address: Address(careOf: "", country: "", district: "", house: "", landmark: "", locality: "", pincode: "", postOffice: "", state: "", street: "", subDistrict: "", vtc: ""),
                encodedImage: "", aadharNum: ""
            )
        } else if elementName == "Poi" {
            kycData?.name = attributeDict["name"] ?? ""
            kycData?.dob = attributeDict["dob"] ?? ""
            kycData?.gender = attributeDict["gender"] ?? ""
            kycData?.email = attributeDict["email"] ?? ""
            kycData?.mob = attributeDict["mob"] ?? ""
        } else if elementName == "Poa" {
            address = Address(
                careOf: attributeDict["careof"] ?? "",
                country: attributeDict["country"] ?? "",
                district: attributeDict["dist"] ?? "",
                house: attributeDict["house"] ?? "",
                landmark: attributeDict["landmark"] ?? "",
                locality: attributeDict["loc"] ?? "",
                pincode: attributeDict["pc"] ?? "",
                postOffice: attributeDict["po"] ?? "",
                state: attributeDict["state"] ?? "",
                street: attributeDict["street"] ?? "",
                subDistrict: attributeDict["subdist"] ?? "",
                vtc: attributeDict["vtc"] ?? ""
            )
            kycData?.address = address!
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if currentElement == "Pht" {
            kycData?.encodedImage = string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

class SharedDataModel: ObservableObject {
    @Published var kycData: KYCData?

    func saveData(_ data: KYCData) {
        self.kycData = data
        UserDefaults.standard.set(data.referenceId, forKey: "referenceId")
        UserDefaults.standard.set(data.hashLayer, forKey: "hashLayer")
        UserDefaults.standard.set(data.name, forKey: "name")
        UserDefaults.standard.set(data.gender, forKey: "gender")
        UserDefaults.standard.set(data.email, forKey: "email")
        UserDefaults.standard.set(data.mob, forKey: "mob")
        UserDefaults.standard.set(data.dob, forKey: "dob")
        UserDefaults.standard.set(data.address.careOf, forKey: "careof")
        UserDefaults.standard.set(data.address.country, forKey: "country")
        UserDefaults.standard.set(data.address.district, forKey: "dist")
        UserDefaults.standard.set(data.address.house, forKey: "house")
        UserDefaults.standard.set(data.address.landmark, forKey: "landmark")
        UserDefaults.standard.set(data.address.locality, forKey: "loc")
        UserDefaults.standard.set(data.address.pincode, forKey: "pc")
        UserDefaults.standard.set(data.address.postOffice, forKey: "po")
        UserDefaults.standard.set(data.address.state, forKey: "state")
        UserDefaults.standard.set(data.address.street, forKey: "street")
        UserDefaults.standard.set(data.address.subDistrict, forKey: "subdist")
        UserDefaults.standard.set(data.encodedImage, forKey: "encodedImage")
        UserDefaults.standard.set(data.aadharNum, forKey: "aadharNum")
    }

    func fetchSavedData() {
        let referenceId = UserDefaults.standard.string(forKey: "referenceId") ?? ""
        let hashLayer = UserDefaults.standard.integer(forKey: "hashLayer")
        let name = UserDefaults.standard.string(forKey: "name") ?? ""
        let gender = UserDefaults.standard.string(forKey: "gender") ?? ""
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        let mob = UserDefaults.standard.string(forKey: "mob") ?? ""
        let dob = UserDefaults.standard.string(forKey: "dob") ?? ""
        let careof = UserDefaults.standard.string(forKey: "careof") ?? ""
        let country = UserDefaults.standard.string(forKey: "country") ?? ""
        let dist = UserDefaults.standard.string(forKey: "dist") ?? ""
        let house = UserDefaults.standard.string(forKey: "house") ?? ""
        let landmark = UserDefaults.standard.string(forKey: "landmark") ?? ""
        let loc = UserDefaults.standard.string(forKey: "loc") ?? ""
        let pc = UserDefaults.standard.string(forKey: "pc") ?? ""
        let po = UserDefaults.standard.string(forKey: "po") ?? ""
        let state = UserDefaults.standard.string(forKey: "state") ?? ""
        let street = UserDefaults.standard.string(forKey: "street") ?? ""
        let subdist = UserDefaults.standard.string(forKey: "subdist") ?? ""
        let encodedImage = UserDefaults.standard.string(forKey: "encodedImage") ?? ""
        let aadharNum = UserDefaults.standard.string(forKey: "aadharNum") ?? ""
        
        self.kycData = KYCData(
            id: referenceId,
            referenceId: referenceId,
            hashLayer: hashLayer,
            name: name,
            dob: dob,
            gender: gender,
            email: email,
            mob: mob,
            address: Address(
                careOf: careof,
                country: country,
                district: dist,
                house: house,
                landmark: landmark,
                locality: loc,
                pincode: pc,
                postOffice: po,
                state: state,
                street: street,
                subDistrict: subdist,
                vtc: ""
            ),
            encodedImage: encodedImage,
            aadharNum: aadharNum
        )
    }

    func resetData() {
        self.kycData = KYCData(
            id: "",
            referenceId: "",
            hashLayer: 1,
            name: "",
            dob: "",
            gender: "",
            email: "",
            mob: "",
            address: Address(
                careOf: "",
                country: "",
                district: "",
                house: "",
                landmark: "",
                locality: "",
                pincode: "",
                postOffice: "",
                state: "",
                street: "",
                subDistrict: "",
                vtc: ""
            ),
            encodedImage: "",
            aadharNum: ""
        )
    }
}

struct SettingsView: View {

    @StateObject var sharedDataModel = SharedDataModel()
    @StateObject private var fileCoordinator = FileCoordinator(sharedDataModel: SharedDataModel())
    @State private var showingFAQSheet = false
    @State private var showingAboutMeSheet = false


    var body: some View {
        VStack {
            List{
                Section {
                    Button(action: {
                        fileCoordinator.startFileImport()
                    }) {
                        Label("Load Data", systemImage: "person.text.rectangle")
                    }
                    .accentColor(.green)
                    Button(action: {
                        //sharedDataModel.resetData() No clue why this does not work!
                        sharedDataModel.saveData(KYCData(id: "", referenceId: "", hashLayer: 1, name: "", dob: "", gender: "", email: "", mob:"", address: Address(careOf: "", country: "", district: "", house: "", landmark: "", locality: "", pincode: "", postOffice: "", state: "", street: "", subDistrict: "", vtc: ""), encodedImage: "", aadharNum: ""))
                        
                        fileCoordinator.alertMessage = "Reset Succesfully"
                        fileCoordinator.showAlert = true
                    }) {
                        Label("Reset", systemImage: "trash")
                    }
                    .accentColor(.red)
                } header: {
                    Text("Data")
                }
                Section {
                    Button("FAQ") {
                        showingFAQSheet.toggle()
                            }
                            .sheet(isPresented: $showingFAQSheet) {
                                NavigationStack {
                                    faqView()
                                }
                            }
                    Button("About the developer") {
                        showingAboutMeSheet.toggle()
                            }
                            .sheet(isPresented: $showingAboutMeSheet) {
                                NavigationStack {
                                    aboutMeSheet()
                                }
                            }
                } header: {
                    Text("FAQ")
                }


                
            }
            .listItemTint(.accentColor)
            .navigationTitle("Settings")
        }
        .alert(isPresented: $fileCoordinator.showAlert) {
            Alert(title: Text("Alert"), message: Text(fileCoordinator.alertMessage), dismissButton: .default(Text("OK")))
        }
        .fileImporter(
            isPresented: $fileCoordinator.isDocumentPickerPresented,
            allowedContentTypes: [.archive],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                files.forEach { file in
                    let gotAccess = file.startAccessingSecurityScopedResource()
                    if !gotAccess { return }
                    fileCoordinator.requestPassword(for: file)
                }
            case .failure(let error):
                fileCoordinator.alertMessage = "Import Failed: \(error.localizedDescription)"
                fileCoordinator.showAlert = true
            }
        }
    }
}

class FileCoordinator: NSObject, ObservableObject {
    @Published var showAlert = false
    @Published var showAlert2 = false
    @Published var alertMessage = ""
    @Published var isDocumentPickerPresented = false
    
    private var sharedDataModel: SharedDataModel
    
    init(sharedDataModel: SharedDataModel) {
        self.sharedDataModel = sharedDataModel
    }
    
    func startFileImport() {
        isDocumentPickerPresented = true
    }
    
    func reset() {
        print("trying to reset")
        sharedDataModel.resetData()
    }
    
    func requestPassword(for fileURL: URL) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            alertMessage = "Unable to access the root view controller."
            showAlert = true
            return
        }

        let alert = UIAlertController(title: "Enter Password", message: "The zip file is protected. Please enter the password.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let passwordField = alert.textFields?.first, let password = passwordField.text {
                self.unzipFile(fileURL: fileURL, password: password)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.alertMessage = "Operation cancelled by user."
            self.showAlert = true
        })
        rootViewController.present(alert, animated: true)
    }

    private func unzipFile(fileURL: URL, password: String) {
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        do {
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try Zip.unzipFile(fileURL, destination: destinationURL, overwrite: true, password: password)
            processUnzippedFiles(at: destinationURL)
        } catch let zipError as ZipError {
            switch zipError {
            case .fileNotFound:
                alertMessage = "File not found at path: \(fileURL)"
            case .unzipFail:
                alertMessage = "Failed to unzip the file. Possible reasons: corrupted zip, incorrect password."
            case .zipFail:
                alertMessage = "Failed to zip the file."
            }
            showAlert = true
        } catch {
            alertMessage = "An error occurred: \(error.localizedDescription)\nURL: \(fileURL)\ndestination: \(destinationURL)"
            showAlert = true
        }
    }

    private func processUnzippedFiles(at destinationURL: URL) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: nil)
            if let xmlFile = contents.first(where: { $0.pathExtension == "xml" }) {
                let xmlData = try Data(contentsOf: xmlFile)
                if let kycData = KYCParser().parse(data: xmlData) {
                    sharedDataModel.saveData(kycData)
                    requestAadharNumber()
                } else {
                    alertMessage = "Failed to parse the XML file."
                    showAlert = true
                }
            } else {
                alertMessage = "No XML file found in the unzipped contents."
                showAlert = true
            }
        } catch {
            alertMessage = "Failed to process the unzipped files: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func requestAadharNumber() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            alertMessage = "Unable to access the root view controller."
            showAlert = true
            return
        }

        let alert = UIAlertController(title: "Enter Aadhar Number", message: "Please enter the 12-digit Aadhar number.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "XXXX"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "XXXX"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "XXXX"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let firstField = alert.textFields?[0], let secondField = alert.textFields?[1], let thirdField = alert.textFields?[2],
               let firstPart = firstField.text, let secondPart = secondField.text, let thirdPart = thirdField.text {
                let aadharNumber = firstPart + secondPart + thirdPart
                if firstPart.count != 4 || secondPart.count != 4 || thirdPart.count != 4 {
                    self.alertMessage = "Invalid Aadhar number. Please enter 12 digits."
                    self.showAlert = true
                } else {
                    if aadharNumber.count == 12 {
                        if thirdPart == "\(self.sharedDataModel.kycData?.referenceId.prefix(4) ?? "")" {
                            self.sharedDataModel.kycData?.aadharNum = aadharNumber
                            UserDefaults.standard.set(aadharNumber, forKey: "aadharNum")
                        } else {
                            UserDefaults.standard.set("", forKey: "aadharNum")
                            self.alertMessage = "Invalid Aadhar number. Last 4 digits do not match!"
                            self.showAlert = true
                        }
                    } else {
                        self.alertMessage = "Invalid Aadhar number. Please enter 12 digits."
                        self.showAlert = true
                    }
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        rootViewController.present(alert, animated: true)
    }
}

struct faqView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Where to download your Aadhar Card xml file from?")
                .font(.headline)
                .padding(.bottom, 5)
            Text("Visit [UIDAI](https://uidai.gov.in/en/307-english-uk/faqs/aadhaar-online-services/aadhaar-paperless-offline-e-kyc/10731-how-to-generate-offline-aadhaar-2.html) for latest instructions")
                .padding(.bottom, 5)
            Image("faqSS")
                .resizable() // Assuming you want the image to be resizable
                .aspectRatio(contentMode: .fit) // Assuming you want to maintain aspect ratio
                .padding(.bottom, 5)
            Text("Once downloaded, Load Data via Settings in this app. Use the same phase phrase")
                .padding(.bottom, 5)
            Spacer()
        }
        .padding(10.0)
        .navigationTitle("How to download")
    }
}


struct PictureView: View {
    @ObservedObject var sharedDataModel: SharedDataModel

    var body: some View {
        VStack {
            if let image = decodeBase64String(sharedDataModel.kycData?.encodedImage ?? "") {
                Image(uiImage: image)
                    //.resizable()
                    .frame(width: 160.0, height: 200.0)
                    //.scaledToFit()

            } else {
                Spacer()
                ZStack{
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.gray)
                        .frame(width: 160.0, height: 200.0)
                    Text("Load aadhar card").padding(10)
                }
                
                
                Spacer()
                
            }
        }
        .frame(width: 160, height: 200)
        .onAppear {
            sharedDataModel.fetchSavedData()
        }
    }

    private func decodeBase64String(_ base64String: String) -> UIImage? {
        if let imageData = Data(base64Encoded: base64String) {
            return UIImage(data: imageData)
        }
        return nil
    }
}

struct AddressView: View {
    @ObservedObject var sharedDataModel: SharedDataModel
    
    

    var body: some View {
        if let address = sharedDataModel.kycData?.address, !address.careOf.isEmpty {
            VStack(alignment: .leading) {
                Text("Address").font(.subheadline)
                Text("\(address.careOf), \(address.house), \(address.street)")
                Text("\(address.landmark), \(address.locality), \(address.vtc)")
                Text("\(address.district), \(address.state), \(address.country)")
                Text("\(address.pincode)")
            }
        } else {
            VStack(alignment: .leading) {
                Text("Address").font(.subheadline)
                Text("Not loaded")
            }
        }
    }
}

struct NamesView: View {
    @ObservedObject var sharedDataModel: SharedDataModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Name").font(.subheadline)
            Text("\(sharedDataModel.kycData?.name ?? "")").font(.title3).fontWeight(.semibold).fixedSize(horizontal: false, vertical: true)
            Text("Gender").font(.subheadline)
            Text("\(sharedDataModel.kycData?.gender ?? "")").font(.title3).fontWeight(.semibold)
            Text("DOB").font(.subheadline)
            Text("\(sharedDataModel.kycData?.dob ?? "")").font(.title3).fontWeight(.semibold)
        }
        .onAppear {
            sharedDataModel.fetchSavedData()
        }
        .padding()
    }
}

enum ViewPicker: Identifiable{
    case reset
    var id: Int{
        hashValue
    }
}

struct LoadFileView: View {
    @ObservedObject var sharedDataModel: SharedDataModel
    @State private var isDocumentPickerPresented = false
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var ViewPicker: ViewPicker?

    var body: some View {
        VStack {
            Button(action: {
                        isDocumentPickerPresented.toggle()
                    }) {
                        Text("Load Zip File")
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .fileImporter(
                        isPresented: $isDocumentPickerPresented,
                        allowedContentTypes: [.archive],
                        allowsMultipleSelection: false
                    ) { result in
                        switch result {
                        case .success(let files):
                            files.forEach { file in
                                let gotAccess = file.startAccessingSecurityScopedResource()
                                if !gotAccess {return}
                                requestPassword(for: file)
                            }
                        case .failure(let error):
                            alertMessage = "Import Failed"
                            showAlert = true
                            print("Failed to import file: \(error.localizedDescription)")
                        }
                    }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }


    private func requestPassword(for fileURL: URL) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            alertMessage = "Unable to access the root view controller."
            showAlert = true
            return
        }

        let alert = UIAlertController(title: "Enter Password", message: "The zip file is protected. Please enter the password.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let passwordField = alert.textFields?.first, let password = passwordField.text {
                unzipFile(fileURL: fileURL, password: password)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        rootViewController.present(alert, animated: true)
    }

    private func unzipFile(fileURL: URL, password: String) {
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        do {
            // Create the directory at destinationURL
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            
            // Check if the directory was created successfully
            var isDirectory: ObjCBool = true
            let directoryExists = FileManager.default.fileExists(atPath: destinationURL.path, isDirectory: &isDirectory)
            
            let folderPath = fileURL.deletingLastPathComponent()
            print(folderPath)
            do {
                let items = try FileManager.default.contentsOfDirectory(atPath: Bundle.main.resourcePath!)

                for item in items {
                    print("Found \(item)")
                }
            } catch {
                print("enum failed")
            }
            
            
            
            if directoryExists && isDirectory.boolValue {
                do {
                    
                    if FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false), isDirectory: nil) {
                        print("File exists!")
                        print(fileURL)
                    } else {
                        print("Nope")
                        print(fileURL)
                    }
                    
                    // Unzip the file to the created directory
                    try Zip.unzipFile(fileURL, destination: destinationURL, overwrite: true, password: password)
                    
                    // Process the unzipped files
                    processUnzippedFiles(at: destinationURL)
                } catch let zipError as ZipError {
                    // Handle specific ZipError cases
                    switch zipError {
                    case .fileNotFound:
                        alertMessage = "File not found at path: \(fileURL)"
                    case .unzipFail:
                        alertMessage = "Failed to unzip the file. Possible reasons: corrupted zip, incorrect password."
                    case .zipFail:
                        alertMessage = "Failed to zip the file."
                    }
                    showAlert = true
                }
            } else {
                alertMessage = "File not found at path v1: \(fileURL)"
                showAlert = true
            }
            
        } catch {
            // Handle any other errors that occur
            alertMessage = "An error occurred: \(error.localizedDescription)\nURL: \(fileURL)\ndestination: \(destinationURL)"
            showAlert = true
        }
    }


    private func processUnzippedFiles(at destinationURL: URL) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: nil)
            if let xmlFile = contents.first(where: { $0.pathExtension == "xml" }) {
                let xmlData = try Data(contentsOf: xmlFile)
                if let kycData = KYCParser().parse(data: xmlData) {
                    sharedDataModel.saveData(kycData)
                    requestAadharNumber()
                } else {
                    alertMessage = "Failed to parse the XML file."
                    showAlert = true
                }
            } else {
                alertMessage = "No XML file found in the unzipped contents."
                showAlert = true
            }
        } catch {
            alertMessage = "Failed to process the unzipped files: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func requestAadharNumber() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            alertMessage = "Unable to access the root view controller."
            showAlert = true
            return
        }

        let alert = UIAlertController(title: "Enter Aadhar Number", message: "Please enter the 12-digit Aadhar number.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "XXXX"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "XXXX"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "XXXX"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let firstField = alert.textFields?[0], let secondField = alert.textFields?[1], let thirdField = alert.textFields?[2],
               let firstPart = firstField.text, let secondPart = secondField.text, let thirdPart = thirdField.text {
                let aadharNumber = firstPart + secondPart + thirdPart
                if firstPart.count != 4 || secondPart.count != 4 || thirdPart.count != 4 {
                    self.alertMessage = "Invalid Aadhar number. Please enter 12 digits."
                    self.showAlert = true
                } else {
                    if aadharNumber.count == 12 {
                        if thirdPart == "\(sharedDataModel.kycData?.referenceId.prefix(4) ?? "")" {
                            sharedDataModel.kycData?.aadharNum = aadharNumber
                            UserDefaults.standard.set(aadharNumber, forKey: "aadharNum") // Save Aadhar number to UserDefaults
                        } else {
                            UserDefaults.standard.set("", forKey: "aadharNum")
                            self.alertMessage = "Invalid Aadhar number. Last 4 digits do not match!"
                            self.showAlert = true
                        }
                    } else {
                        self.alertMessage = "Invalid Aadhar number. Please enter 12 digits."
                        self.showAlert = true
                    }
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        rootViewController.present(alert, animated: true)
    }

}

struct ResetView: View {
    @ObservedObject var sharedDataModel: SharedDataModel

    var body: some View {
        Button(action: {
            sharedDataModel.resetData()
        }) {
            Text("Reset")
                .foregroundColor(.black)
        }
    }
}

struct AadharNumberView: View {
    @ObservedObject var sharedDataModel: SharedDataModel
    @State private var refToggle = false

    var reference: String {
        if let aadharNum = sharedDataModel.kycData?.aadharNum {
            return refToggle ? (aadharNum.isEmpty ? "Aadhar number not loaded yet" : formattedAadharNumber(aadharNum)) :
                "XXXX XXXX \(sharedDataModel.kycData?.referenceId.prefix(4) ?? "XXXX")"
        } else {
            return "No aadhar card number loaded"
        }
    }

    var body: some View {
        VStack {
            
            Button(action: {
                refToggle.toggle()
            }) {
                Text(reference)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.black)
                    .foregroundColor(.blue)
            }
        }
        .onAppear {
            sharedDataModel.fetchSavedData()
        }
    }

    private func formattedAadharNumber(_ aadharNum: String) -> String {
        var formattedString = ""
        for (index, char) in aadharNum.enumerated() {
            if index > 0 && index % 4 == 0 {
                formattedString += " \(char)"
            } else {
                formattedString += String(char)
            }
        }
        return formattedString
    }
}

struct CardView: View {
    @ObservedObject var sharedDataModel: SharedDataModel
    @Environment(\.colorScheme) var colorScheme
        private var shadowColor: Color {
                return colorScheme == .light ? .gray : .gray
            }
    private let greenColor = Color(red: 162/255, green: 250/255, blue: 186/255)
    private let orangeColor = Color(red: 255/255, green: 179/255, blue: 112/255)
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [greenColor, Color.white, Color.white, orangeColor]), startPoint: .bottom, endPoint: .top)
            VStack(alignment: .leading){
                HStack(alignment: .top) {
                    PictureView(sharedDataModel: sharedDataModel)
                        .cornerRadius(5)
                    NamesView(sharedDataModel: sharedDataModel)
                }
                HStack {
                    Spacer()
                    AadharNumberView(sharedDataModel: sharedDataModel)
                    Spacer()
                }
            }.padding(10)
        }
        .frame(height: 275)
        .cornerRadius(5)
        .foregroundColor(.black)
        .shadow(color: shadowColor, radius: 20, x:0, y:15)

    }
}

struct ContentView: View {
    @StateObject var sharedDataModel = SharedDataModel()

    var body: some View {
        NavigationStack {
            ZStack {
//                LinearGradient(gradient: Gradient(colors: [Color.orange, Color(hue: 1, saturation: 0.7, brightness: 1)]), startPoint: .bottomTrailing, endPoint: .trailing)
//                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    CardView(sharedDataModel: sharedDataModel)
                    AddressView(sharedDataModel: sharedDataModel).padding(10)
                    Spacer()
                    HStack {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            }
            .padding(10)
            .navigationTitle("MyAadhar")
            //.navigationBarTitleTextColor(.black)
        }
    }
}

extension View {
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
        return self
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//        faqView()
    }
}

