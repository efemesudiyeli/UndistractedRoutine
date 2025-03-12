import SwiftUI

struct PetCardView: View {
    let pet: Pet
    let scale: CGFloat
    let isCompact: Bool
    @State private var isAnimating = false
    
    init(pet: Pet, scale: CGFloat = 1.0, isCompact: Bool = true) {
        self.pet = pet
        self.scale = scale
        self.isCompact = isCompact
    }
    
    var body: some View {
        VStack(spacing: isCompact ? 8 : 12) {
            if !isCompact {
                Text(pet.displayName)
                    .font(.headline)
            }
            
            Text(pet.type.emoji)
                .font(.system(size: isCompact ? 40 : 60))
                .scaleEffect(scale)
                .offset(y: isAnimating ? -3 : 3)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            if isCompact {
                compactInfoView
            } else {
                detailedInfoView
            }
        }
        .frame(width: isCompact ? 80 : nil)
        .padding(.vertical, 8)
        .padding(.horizontal, isCompact ? 0 : 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 3)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private var compactInfoView: some View {
        VStack(spacing: 4) {
            Text(pet.name)
                .font(.caption)
                .fontWeight(.medium)
            
            HStack(spacing: 4) {
                Text("Lv.\(pet.level)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(pet.happinessEmoji)
                    .font(.caption2)
            }
        }
    }
    
    private var detailedInfoView: some View {
        VStack(spacing: 12) {
            HStack {
                Text(pet.rarityBadge)
                Text(pet.type.rarity.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text(pet.happinessEmoji)
                ProgressView(value: Double(pet.happiness), total: 100)
                    .tint(pet.happiness > 50 ? .green : .red)
            }
            
            ProgressView(value: Double(pet.experience), total: Double(pet.experienceNeededForNextLevel))
                .tint(.blue)
            Text("Level \(pet.level)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
} 