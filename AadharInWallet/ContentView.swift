import SwiftUI
import Combine
import Zip
import Foundation

struct KYCData: Identifiable {
    var id: String // This is for Identifiable protocol
    var referenceId: String // New property for the reference ID
    var name: String
    var dob: String
    var gender: String
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
                name: "",
                dob: "",
                gender: "",
                address: Address(careOf: "", country: "", district: "", house: "", landmark: "", locality: "", pincode: "", postOffice: "", state: "", street: "", subDistrict: "", vtc: ""),
                encodedImage: "", aadharNum: ""
            )
        } else if elementName == "Poi" {
            kycData?.name = attributeDict["name"] ?? ""
            kycData?.dob = attributeDict["dob"] ?? ""
            kycData?.gender = attributeDict["gender"] ?? ""
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
        UserDefaults.standard.set(data.name, forKey: "name")
        UserDefaults.standard.set(data.gender, forKey: "gender")
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
        
        // Save other fields similarly
        UserDefaults.standard.set(data.encodedImage, forKey: "encodedImage")
        UserDefaults.standard.set(data.aadharNum, forKey: "aadharNum")
    }

    func fetchSavedData() {
        // Fetch data from UserDefaults and populate kycData
        // Ensure all fields are fetched and assigned
        let referenceId = UserDefaults.standard.string(forKey:  "referenceId") ?? ""
        let name = UserDefaults.standard.string(forKey: "name") ?? ""
        let gender = UserDefaults.standard.string(forKey: "gender") ?? ""
        let dob = UserDefaults.standard.string(forKey: "dob") ?? ""
        
        let careof = UserDefaults.standard.string(forKey: "careof") ?? ""
        let country = UserDefaults.standard.string(forKey: "country") ?? ""
        let dist = UserDefaults.standard.string(forKey: "dist") ?? ""
        
        let house = UserDefaults.standard.string(forKey: "house") ?? ""
        let landmark = UserDefaults.standard.string(forKey: "landmark") ?? ""
        let loc = UserDefaults.standard.string(forKey: "loc") ?? ""
        
        let pc = UserDefaults.standard.string(forKey: "pc") ?? ""
        let po = UserDefaults.standard.string(forKey:"po") ?? ""
        let state = UserDefaults.standard.string(forKey: "state") ?? ""
        
        let street = UserDefaults.standard.string(forKey: "street") ?? ""
        let subdist = UserDefaults.standard.string(forKey: "subdist") ?? ""
        
        let encodedImage = UserDefaults.standard.string(forKey: "encodedImage") ?? ""
        let aadharNum = UserDefaults.standard.string(forKey: "aadharNum") ?? ""
        // Fetch other fields similarly
        self.kycData = KYCData(id: "", referenceId: referenceId, name: name, dob: dob, gender: gender, address: Address(careOf: careof, country: country, district: dist, house: house, landmark: landmark, locality: loc, pincode: pc, postOffice: po, state: state, street: street, subDistrict: subdist, vtc: ""), encodedImage: encodedImage, aadharNum: aadharNum)
    }
    
    func resetData() {
           self.kycData = KYCData(id: "", referenceId: "", name: "", dob: "", gender: "", address: Address(careOf: "", country: "", district: "", house: "", landmark: "", locality: "", pincode: "", postOffice: "", state: "", street: "", subDistrict: "", vtc: ""), encodedImage: "", aadharNum: "")
       }
}

struct PictureView: View {
    @ObservedObject var sharedDataModel: SharedDataModel

    var body: some View {
        VStack {
            if let image = decodeBase64String(sharedDataModel.kycData?.encodedImage ?? "") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()

            } else {
                Spacer()
                ZStack{
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.gray)
                    Text("Aadhar card file corrupted, or not available. Try again. ").padding(10)
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
        if let address = sharedDataModel.kycData?.address {
            VStack(alignment: .leading) {
                Text("Address").font(.subheadline)
                Text("\(address.careOf), \(address.house), \(address.street)")
                Text("\(address.landmark), \(address.locality), \(address.vtc)")
                Text("\(address.district), \(address.state), \(address.country)")
                Text("Pincode: \(address.pincode)")
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


struct LoadFileView: View {
    @ObservedObject var sharedDataModel: SharedDataModel
    @State private var isDocumentPickerPresented = false
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Button(action: {
                isDocumentPickerPresented.toggle()
            }) {
                Text("Load Zip File")
                    .padding()
                    .background(Color.gray)
                    .opacity(0.8)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .fileImporter(
                isPresented: $isDocumentPickerPresented,
                allowedContentTypes: [.archive],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result: result)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func handleFileImport(result: Result<[URL], Error>) {
        do {
            let selectedFileURL = try result.get().first!
            requestPassword(for: selectedFileURL)
        } catch {
            alertMessage = "Failed to load the file."
            showAlert = true
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
                self.password = password
                self.unzipFile(fileURL: fileURL, password: password)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        rootViewController.present(alert, animated: true)
    }

    private func unzipFile(fileURL: URL, password: String) {
        do {
            let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try Zip.unzipFile(fileURL, destination: destinationURL, overwrite: true, password: password)
            processUnzippedFiles(at: destinationURL)
        } catch {
            alertMessage = "Failed to unzip the file: \(error.localizedDescription)"
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
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        rootViewController.present(alert, animated: true)
    }

}



struct restView: View {
    @ObservedObject var sharedDataModel = SharedDataModel()
    
    var body: some View {
        Button {
            sharedDataModel.resetData()
        } label: {
            Text("Reset")
                .foregroundStyle(Color.black)
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
                switchReference()
            }) {
                Text(reference).font(.title2).bold()
            }
        }
        .onAppear {
            sharedDataModel.fetchSavedData()
        }
    }

    func switchReference() {
        refToggle.toggle()
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




struct ContentView: View {
    @StateObject private var sharedDataModel = SharedDataModel()
    

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.orange, Color(hue: 1, saturation: 0.7, brightness: 1)]), startPoint: .bottomTrailing, endPoint: .trailing).ignoresSafeArea()
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                    .opacity(0.7)
                    .padding(10.0)
                VStack(alignment: .leading) {
                    HStack{
                        Spacer()
                        AadharNumberView(sharedDataModel: sharedDataModel)

                        Spacer()
                    }
                    HStack(alignment: .top) {
                        PictureView(sharedDataModel: sharedDataModel)
                            .cornerRadius(5)
                        NamesView(sharedDataModel: sharedDataModel)
                    }
                    AddressView(sharedDataModel: sharedDataModel)
                    Spacer()
                    HStack{
                        LoadFileView(sharedDataModel: sharedDataModel)
                        restView(sharedDataModel: sharedDataModel)
                    }.padding(-10)
                    
                    .padding(10)

                }
                .padding(30)
                .navigationTitle("Aadhar in Wallet")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
