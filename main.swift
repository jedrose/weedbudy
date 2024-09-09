import SwiftUI
import UIKit

// Data Model for Post
struct Post: Identifiable {
    var id = UUID()
    var username: String
    var frontCameraImage: UIImage
    var backCameraImage: UIImage
    var method: String
    var timestamp: Date
}

// Data Model for Friends
struct Friend: Identifiable {
    var id = UUID()
    var username: String
}

// Main App
@main
struct WeedbuddyApp: App {
    @StateObject private var appData = AppData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
        }
    }
}

// ViewModel for App State
class AppData: ObservableObject {
    @Published var posts: [Post] = []
    @Published var currentUser: String = "User123"
    @Published var isHigh: Bool = false
    @Published var friends: [Friend] = []
    @Published var showSmoke: Bool = false
}

// ContentView - Main screen for the app
struct ContentView: View {
    @EnvironmentObject var appData: AppData
    @State private var showingQuestion = true
    @State private var showingImagePicker = false
    @State private var frontImage: UIImage? = nil
    @State private var backImage: UIImage? = nil
    @State private var selectedMethod: String = ""
    @State private var showFriendLink = false

    let methods = ["Joint", "Vape", "Edible", "Dab", "Other"]

    var body: some View {
        ZStack {
            // Green and Black Theme
            Color.black.ignoresSafeArea()

            VStack {
                if showingQuestion {
                    VStack {
                        Text("Are you high?")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                        HStack {
                            Button(action: {
                                appData.isHigh = true
                                showingQuestion = false
                                showingImagePicker = true
                            }) {
                                Text("Yes")
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Button(action: {
                                appData.isHigh = false
                                showingQuestion = false
                            }) {
                                Text("No")
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                } else if showingImagePicker {
                    // Capture front and back camera photos
                    ImagePickerView(frontImage: $frontImage, backImage: $backImage)
                        .onDisappear {
                            if let front = frontImage, let back = backImage {
                                showingImagePicker = false
                            }
                        }
                } else if appData.isHigh {
                    // After photo capture, select the method
                    VStack {
                        Text("Select the cannabis method")
                            .foregroundColor(.green)
                        Picker("Method", selection: $selectedMethod) {
                            ForEach(methods, id: \.self) { method in
                                Text(method)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .foregroundColor(.green)
                        Button(action: {
                            if let frontImage = frontImage, let backImage = backImage {
                                let newPost = Post(username: appData.currentUser, frontCameraImage: frontImage, backCameraImage: backImage, method: selectedMethod, timestamp: Date())
                                appData.posts.append(newPost)
                                appData.showSmoke = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    appData.showSmoke = false
                                }
                            }
                            appData.isHigh = false
                        }) {
                            Text("Post")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    // Home page: Display other users' photos and friends
                    HomePageView(posts: appData.posts, friends: appData.friends)
                    
                    Button(action: {
                        showFriendLink = true
                    }) {
                        Text("Add Friend")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }

            if showFriendLink {
                FriendLinkView(showFriendLink: $showFriendLink)
            }

            if appData.showSmoke {
                SmokeView()
            }
        }
    }
}

// HomePageView to view posts and friends
struct HomePageView: View {
    var posts: [Post]
    var friends: [Friend]

    var body: some View {
        VStack {
            List(posts) { post in
                VStack(alignment: .leading) {
                    Text("User: \(post.username)")
                        .font(.headline)
                        .foregroundColor(.green)
                    Text("Method: \(post.method)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    HStack {
                        Image(uiImage: post.frontCameraImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                        Image(uiImage: post.backCameraImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    Text("Posted at: \(post.timestamp, formatter: postDateFormatter)")
                        .foregroundColor(.white)
                }
            }
            .background(Color.black)

            List(friends) { friend in
                Text("Friend: \(friend.username)")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            .background(Color.black)
        }
    }
}

// ImagePicker for capturing front and back camera photos
struct ImagePickerView: View {
    @Binding var frontImage: UIImage?
    @Binding var backImage: UIImage?
    @State private var showFrontCamera = true
    @State private var showCamera = false

    var body: some View {
        VStack {
            if showCamera {
                CameraView(image: showFrontCamera ? $frontImage : $backImage)
                    .onDisappear {
                        if showFrontCamera {
                            showFrontCamera = false
                            showCamera = true
                        }
                    }
            } else {
                Button(action: {
                    showCamera = true
                }) {
                    Text("Take Photos")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}

// Smoke Effect View
struct SmokeView: View {
    var body: some View {
        Color.white.opacity(0.5)
            .edgesIgnoringSafeArea(.all)
            .transition(.opacity)
            .animation(.easeInOut(duration: 2))
    }
}

// FriendLinkView to share friend link
struct FriendLinkView: View {
    @Binding var showFriendLink: Bool

    var body: some View {
        VStack {
            Text("Share this link with your friend:")
                .foregroundColor(.green)
            Text("weedbuddy://addfriend/User123")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            Button(action: {
                showFriendLink = false
            }) {
                Text("Close")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
        .edgesIgnoringSafeArea(.all)
    }
}

// CameraView for capturing images
struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// Formatter for Post date display
private let postDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
