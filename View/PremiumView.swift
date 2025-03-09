import SwiftUI

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var premiumManager = PremiumManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .center, spacing: 16) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.yellow)
                        
                        Text("Premium'a Geç")
                            .font(.title2)
                            .bold()
                        
                        Text("Tüm özelliklere sınırsız erişim")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                Section(header: Text("Premium Özellikler")) {
                    BenefitRow(icon: "infinity", title: "Sınırsız Görev")
                    BenefitRow(icon: "bell.badge", title: "Sınırsız Bildirim Saati")
                    BenefitRow(icon: "folder.badge.plus", title: "Özel Kategoriler")
                    BenefitRow(icon: "chart.bar.fill", title: "Detaylı İstatistikler")
                    BenefitRow(icon: "icloud", title: "iCloud Yedekleme")
                    BenefitRow(icon: "square.and.arrow.up", title: "Veri Dışa Aktarma")
                    BenefitRow(icon: "paintbrush", title: "Özel Temalar")
                }
                
                Section {
                    Button {
                        // StoreKit entegrasyonu burada yapılacak
                        premiumManager.unlockPremium()
                        dismiss()
                    } label: {
                        Text("Premium'a Geç - ₺49.99")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(title)
        }
    }
} 