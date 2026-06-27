import Foundation

/// Un preset de robe pour le chat.
struct PetPreset: Identifiable, Equatable {
    let id: String
    let name: String
    let body: String
    let belly: String
    let stripe: String
    let eye: String
    let nose: String
}

enum PetCatalog {
    static let presets: [PetPreset] = [
        PetPreset(id: "grey",   name: "Gris cœur", body: "#969BA1", belly: "#F5F5F5",
                  stripe: "#3C4045", eye: "#141414", nose: "#CE2828"),
        PetPreset(id: "orange", name: "Roux",       body: "#E8993A", belly: "#F7E9CE",
                  stripe: "#B5651D", eye: "#2B2B2B", nose: "#D98C8C"),
        PetPreset(id: "black",  name: "Noir",       body: "#3A3A3F", belly: "#9AA0A6",
                  stripe: "#1C1C20", eye: "#7BE0B0", nose: "#E0708A"),
        PetPreset(id: "white",  name: "Blanc",      body: "#ECECEC", belly: "#FFFFFF",
                  stripe: "#C2C2C8", eye: "#5B9BD8", nose: "#E89AAE"),
        PetPreset(id: "siamese",name: "Siamois",    body: "#E7D8C2", belly: "#FBF3E6",
                  stripe: "#6B5036", eye: "#4FA3D1", nose: "#C98C8C"),
        PetPreset(id: "calico", name: "Calico",     body: "#E8A24A", belly: "#FBF3E6",
                  stripe: "#3A3030", eye: "#5BB98A", nose: "#E0708A"),
        PetPreset(id: "blue",   name: "Bleu russe", body: "#6E7E8C", belly: "#C9D2D8",
                  stripe: "#3E4A54", eye: "#7BE0B0", nose: "#C98C9C"),
        PetPreset(id: "mint",   name: "Menthe",     body: "#A8D8C0", belly: "#EFFAF4",
                  stripe: "#5E8C76", eye: "#2B2B2B", nose: "#E0708A"),
    ]
}
