import SwiftUI
import Combine

// ===============================
//  StaffMember 모델
// ===============================
struct StaffMember: Identifiable, Hashable {
    enum Role: String, CaseIterable, Identifiable {
        case manager = "매니저"
        case staff = "스태프"
        var id: String { rawValue }
    }

    let id: UUID
    var name: String
    var startDateText: String
    var role: Role

    init(id: UUID = UUID(), name: String, startDateText: String, role: Role) {
        self.id = id
        self.name = name
        self.startDateText = startDateText
        self.role = role
    }
}

// ===============================
//  StaffStore
// ===============================
final class StaffStore: ObservableObject {

    @Published var members: [StaffMember] = [
        StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .manager),
        StaffMember(name: "김하늘", startDateText: "2022.03.01~", role: .manager),
        StaffMember(name: "박성준", startDateText: "2024.09.10~", role: .staff),
        StaffMember(name: "홍길동", startDateText: "2023.01.15~", role: .staff),
        StaffMember(name: "최예린", startDateText: "2025.06.07~", role: .staff),
    ]

    var managers: [StaffMember] { members.filter { $0.role == .manager } }
    var staffs: [StaffMember] { members.filter { $0.role == .staff } }

    func update(_ updated: StaffMember) {
        guard let idx = members.firstIndex(where: { $0.id == updated.id }) else { return }
        members[idx] = updated
    }

    func delete(_ member: StaffMember) {
        members.removeAll { $0.id == member.id }
    }

    func add(name: String, startDateText: String, role: StaffMember.Role) {
        members.append(StaffMember(name: name, startDateText: startDateText, role: role))
    }
}
