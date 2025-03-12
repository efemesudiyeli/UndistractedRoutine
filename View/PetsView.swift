import SwiftUI

struct PetsView: View {
    @EnvironmentObject private var petViewModel: PetViewModel
    @EnvironmentObject private var taskViewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if petViewModel.pets.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "star.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        
                        Text("Henüz hiç petin yok")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Haftanın %80'ini tamamlayarak yeni bir pet kazanabilirsin!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(petViewModel.pets) { pet in
                            PetCardView(
                                pet: pet,
                                scale: petViewModel.petScale(for: pet),
                                isCompact: false
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Petlerim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tamam") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            petViewModel.checkWeeklyProgress(taskViewModel: taskViewModel)
        }
    }
}

#Preview {
    PetsView()
        .environmentObject(TaskViewModel())
        .environmentObject(PetViewModel())
} 