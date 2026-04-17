import ScrechKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var vm = CoreVM()
    
    @State private var image: UniversalImage? = nil
    
    var body: some View {
        VStack {
            if let image {
#if os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .clipShape(.rect(cornerRadius: 8))
                    .scaledToFit()
                    .frame(200)
#else
                Image(uiImage: image)
                    .resizable()
                    .clipShape(.rect(cornerRadius: 8))
                    .scaledToFit()
                    .frame(200)
#endif
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
                    let url = URL(dataRepresentation: urlData, relativeTo: nil)
                else {
                    return
                }
#if os(macOS)
                guard let uniImage = NSImage(contentsOf: url) else {
                    return
                }
#else
                guard let uniImage = UIImage(contentsOfFile: url.path) else {
                    return
                }
#endif
                print(uniImage.size)
                vm.test(uniImage)
                image = uniImage
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
