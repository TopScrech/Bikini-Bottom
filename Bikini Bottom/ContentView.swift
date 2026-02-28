import ScrechKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var vm = CoreVM()
    
    @State private var image: NSImage? = nil
    
    var body: some View {
        VStack {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .frame(200)
            }
            
            Text(vm.output)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrop(of: [.fileURL], isTargeted: nil) {
            handleDrop($0)
        }
    }
    
    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            guard provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) else {
                return true
            }
            
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { urlData, error in
                guard
                    let urlData = urlData as? Data,
                    let url = URL(dataRepresentation: urlData, relativeTo: nil),
                    let nsImage = NSImage(contentsOf: url)
                else {
                    return
                }
                
                print(nsImage.size)
                vm.test(nsImage)
                image = nsImage
                // images.append(nsImage)
                // processImage(nsImage)
            }
        }
        
        return true
    }
}

#Preview {
    ContentView()
}
