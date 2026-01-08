import SwiftUI
import Combine

// ===============================
//  StaffMember 모델
// ===============================
struct StaffMember: Identifiable, Equatable {
    let id: UUID
    var name: String
    var startDateText: String
    var role: Role

    enum Role: String, CaseIterable, Identifiable {
        case manager = "매니저"
        case staff = "스태프"
        var id: String { rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        startDateText: String,
        role: Role
    ) {
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

    // 상태 변수
    @Published var members: [StaffMember] = [
        StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .manager),
        StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .staff),
        StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .staff),
        StaffMember(name: "이지수", startDateText: "2010.12.25~", role: .staff),
    ]

    // 계산 변수
    var managers: [StaffMember] { members.filter { $0.role == .manager } }
    var staffs: [StaffMember] { members.filter { $0.role == .staff } }

    // 로직 함수
    func update(_ updated: StaffMember) {
        guard let idx = members.firstIndex(where: { $0.id == updated.id }) else { return }
        members[idx] = updated
    }

    func delete(_ member: StaffMember) {
        members.removeAll { $0.id == member.id }
    }

    func add(name: String, startDateText: String, role: StaffMember.Role) {
        let newMember = StaffMember(name: name, startDateText: startDateText, role: role)
        members.append(newMember)
    }
}
