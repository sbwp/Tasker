// ©2024 Sabrina Bea. All rights reserved.

import SwiftUI

struct TaskStatusButton: View {
    @Bindable var task: TaskerTask
    var now: Date
    
    var statusImage: some View {
        let status = task.getStatus(for: now)
        return Image(systemName: status.icon(for: now))
            .font(.system(size: 50))
            .foregroundStyle(status.color(forBackground: task.colorOption, on: now))
    }
    
    var body: some View {
        Button {
            task.toggle(on: now)
        } label: {
            statusImage
        }
    }
}

#Preview {
    TaskStatusButton(task: .forPreview, now: .practicallyNow)
}
