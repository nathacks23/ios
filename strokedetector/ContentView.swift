import SwiftUI

struct ContentView: View {
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var apiResponse: String? // Store API response
    
    var body: some View {
        NavigationView {
            VStack {
                // Display the taken selfie
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    
                    // Button to send the image to the API
                    Button("Send to API") {
                        if let imageData = image.jpegData(compressionQuality: 0.9) {
                            sendImageToAPI(imageData: imageData)
                        }
                    }
                    .padding()
                    
                    // Display API response
                    if let response = apiResponse {
                        Text("API Response: \(response)")
                            .padding()
                    }
                } else {
                    Text("No selfie taken")
                        .padding()
                }
                
                // Button to open the camera for taking a selfie
                Button("Take Selfie") {
                    isImagePickerPresented.toggle()
                }
                .padding()
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $selectedImage)
                }
            }
            .navigationTitle("Stroke Detector App")
        }
    }
    
    // Function to send the image to the API
    func sendImageToAPI(imageData: Data) {
        // Replace "https://strokedetectorr-73f341eb8a5b.herokuapp.com/api/" with your actual API endpoint
        let apiUrlString = "http:172.20.10.9:8000/api/"
        
        guard let apiUrl = URL(string: apiUrlString) else {
            print("Invalid API URL")
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".utf8))
        body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
        body.append(imageData)
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("API Response: \(responseString)")
                    
                    // Update the state variable with API response
                    DispatchQueue.main.async {
                        self.apiResponse = responseString
                    }
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
