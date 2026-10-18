import ISEmojiView
import SwiftUI

struct ContentView: View {
    
    @State private var categoriesText: String = ""
    @State private var pageControlText: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Categories bottom view")) {
                    EmojiTextField(
                        text: $categoriesText,
                        placeholder: "Tap to type with the emoji keyboard",
                        bottomType: .categories,
                        needToShowAbcButton: true
                    )
                    .frame(height: 44)
                    
                    Text(categoriesText.isEmpty ? "Nothing inserted yet" : categoriesText)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Page control bottom view")) {
                    EmojiTextField(
                        text: $pageControlText,
                        placeholder: "Tap to type",
                        bottomType: .pageControl,
                        didPressDismissKeyboard: {}
                    )
                    .frame(height: 44)
                    
                    Text(pageControlText.isEmpty ? "Nothing inserted yet" : pageControlText)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("ISEmojiView")
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
