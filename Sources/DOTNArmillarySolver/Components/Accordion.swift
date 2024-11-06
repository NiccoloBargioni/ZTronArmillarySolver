import SwiftUI
/// A view that supports show/hide operations for its content.
///
/// No animation is assigned to the expansion by default, so it needs to be set from outside,
/// for instance:
///
///     .animation(.easeInOut(duration: 1/6), value: isExpanded)
///
/// This allows the user to form `AccordionGroup`s and collapse the previously opened `Accordion`
/// with a smooth animation, like in the following example.
///
///         @State var selection: Selection? = nil
///
///         func binding(for target: Selection) -> Binding<Bool> {
///             return .init(
///                 get: { selection == target },
///                 set: {
///                     if $0 {
///                         selection = target
///                     } else if selection == target {
///                         selection = nil
///                     }
///                 }
///             )
///         }
///
///         var body: some View {
///             VStack(spacing: 0) {
///                 Accordion(isExpanded: binding(for: .selection1)) {
///                     // Header 1
///                 } content: {
///                     // Content 1
///                 }
///
///                 Accordion(isExpanded: binding(for: .selection2)) {
///                     // Header 2
///                 } content: {
///                     // Content 3
///                 }
///
///                 Accordion(isExpanded: binding(for: .selection3)) {
///                     // Header 3
///                 } content: {
///                     // Content 3
///                 }
///             }
///             .animation(.easeInOut(duration: 1/6), value: selection)
///             .padding()
///         }
///

struct Accordion<Header: View, Content: View>: View {
    @Binding
    var isExpanded: Bool
    let header: Header
    let content: Content

    init(
        isExpanded: Binding<Bool>,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        _isExpanded = isExpanded
        self.header = header()
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                header
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .contentShape(Rectangle())
            .onTapGesture { isExpanded.toggle() }
            content
                .opacity(isExpanded ? 1 : 0)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 16)
                .frame(height: isExpanded ? nil : 0, alignment: .top)
                .clipped()
        }
        .padding()
        .padding(1)
        .border(Color(UIColor.separator), width: 1)
        .background {
            if isExpanded {
                Color(UIColor.tertiarySystemGroupedBackground)
            }
        }
        .padding(-0.5)
    }
}

struct Accordion_Previews: PreviewProvider {
    static var previews: some View {
        Accordion(isExpanded: .constant(true)) {
            Text("Wagliù espandimme")
        } content: {
            Text("Bender Bending Rodríguez (born September 4, 2996), designated Bending Unit 22, and commonly known as Bender, is a bending unit created by a division of MomCorp in Tijuana, Mexico")
                .font(.caption)
        }
    }
}
