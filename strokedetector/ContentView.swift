import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var apiResponse: String?
    @State private var isShowingResults = false

    var body: some View {
        NavigationView {
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()

                    Button("Send to API") {
                        if let imageData = image.jpegData(compressionQuality: 0.9) {
                            sendImageToAPI(imageData: imageData)
                            // Set the flag to show results view
                            isShowingResults = true
                        }
                    }
                    .padding()

                    if let response = apiResponse {
                        Text("API Response: \(response)")
                            .padding()
                    }
                } else {
                    Text("No selfie taken")
                        .padding()
                }

                Button("Take Selfie") {
                    isImagePickerPresented.toggle()
                }
                .padding()
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $selectedImage)
                }
            }
            .navigationTitle("Stroke Detector App")
            .background(
                NavigationLink(
                    destination: ResultsView(apiResponse: $apiResponse),
                    isActive: $isShowingResults,
                    label: { EmptyView() }
                )
            )
        }
    }

    func sendImageToAPI(imageData: Data) {
        // Your existing API request logic

        // For example, updating the response
        apiResponse = "API Response Placeholder"
    }
}

struct ResultsView: View {
    @Binding var apiResponse: String?
    @State private var location: CLLocationCoordinate2D?

    var body: some View {
        VStack {
            Text("Results")
                .font(.title)
                .padding()

            if let response = apiResponse, response != "1" {

                VStack {
                    Button(action: {
                        makeEmergencyCall()
                    }) {
                        Text("Call 911")
                            .foregroundColor(.red)
                            .padding()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 2)
                    )
                    .padding()
                    
                    if let currentLocation = location {
                        Text("Current Location: \(currentLocation.latitude), \(currentLocation.longitude)")
                            .padding()
                    } else {
                        Text("Location not available")
                            .padding()
                    }
                }
            } else {
                Text("Don't Call 911")
                    .foregroundColor(.red)
                    .padding()

                if let currentLocation = location {
                    Text("Current Location: \(currentLocation.latitude), \(currentLocation.longitude)")
                        .padding()
                } else {
                    Text("Location not available")
                        .padding()
                }
            }
        }
        .onAppear {
            getLocation()
        }
        .navigationTitle("Results")
    }
    
    // Function to initiate the emergency call
    func makeEmergencyCall() {
        guard let phoneURL = URL(string: "tel://911"), UIApplication.shared.canOpenURL(phoneURL) else {
            return
        }
        UIApplication.shared.open(phoneURL)
    }
    
    func getLocation() {
        // Use Core Location to get the current location
        // Make sure to handle location permissions in your app
        // Here, I'm using a simple CLLocationManager setup for demonstration purposes

        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()

            if let location = locationManager.location?.coordinate {
                self.location = location
            }
        }
    }
}
