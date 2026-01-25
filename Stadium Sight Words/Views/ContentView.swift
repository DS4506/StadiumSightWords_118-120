
import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.dateAdded, ascending: true)],
        animation: .default
    )
    private var items: FetchedResults<Item>

    @State private var newItemName: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                List {
                    ForEach(items) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name ?? "Unnamed Item")
                                .font(.headline)

                            if let date = item.dateAdded {
                                Text(date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }

                HStack(spacing: 10) {
                    TextField("New Item", text: $newItemName)
                        .textFieldStyle(.roundedBorder)

                    Button(action: addItem) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("My Items")
        }
    }

    private func addItem() {
        let trimmed = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.name = trimmed
            newItem.dateAdded = Date()

            do {
                try viewContext.save()
                newItemName = ""
            } catch {
                print("Failed to save item: \(error.localizedDescription)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                print("Failed to delete item: \(error.localizedDescription)")
            }
        }
    }
}
