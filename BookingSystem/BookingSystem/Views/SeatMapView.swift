import SwiftUI

struct SeatMapView: View {
    let layout: SeatLayout
    @Binding var selectedSeats: [String]
    let maxSelection: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Select Seats")
                .font(.headline)
            
            if layout.rows > 5 {
                ScreenView()
            }
            
            SeatGrid(
                layout: layout,
                selectedSeats: $selectedSeats,
                maxSelection: maxSelection
            )
            
            SeatLegendView()
        }
    }
}

struct ScreenView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .frame(height: 10)
            .foregroundColor(.gray)
            .padding(.bottom, 10)
            .overlay(Text("SCREEN").font(.caption))
    }
}

struct SeatGrid: View {
    let layout: SeatLayout
    @Binding var selectedSeats: [String]
    let maxSelection: Int
    
    var body: some View {
        ForEach(0..<layout.rows, id: \.self) { row in
            HStack(spacing: 8) {
                ForEach(0..<layout.columns, id: \.self) { column in
                    let seatNumber = "\(UnicodeScalar(65 + row)!)\(column + 1)"
                    let isUnavailable = !layout.isSeatAvailable(seatNumber)
                    let isSelected = selectedSeats.contains(seatNumber)
                    
                    SeatButton(
                        seatNumber: seatNumber,
                        isSelected: isSelected,
                        isUnavailable: isUnavailable,
                        isDisabled: !isSelected && selectedSeats.count >= maxSelection
                    ) {
                        if isSelected {
                            selectedSeats.removeAll { $0 == seatNumber }
                        } else {
                            selectedSeats.append(seatNumber)
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
}

struct SeatButton: View {
    let seatNumber: String
    let isSelected: Bool
    let isUnavailable: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if isUnavailable {
            return .gray
        } else if isSelected {
            return .blue
        } else if isDisabled {
            return .gray.opacity(0.2)
        } else {
            return .green
        }
    }
    
    var foregroundColor: Color {
        isSelected || isUnavailable ? .white : .primary
    }
    
    var body: some View {
        Button(action: action) {
            Text(seatNumber)
                .font(.system(size: 10))
                .frame(width: 30, height: 30)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.white, lineWidth: 1)
                )
        }
        .disabled(isUnavailable || isDisabled)
    }
}

struct SeatLegendView: View {
    var body: some View {
        HStack(spacing: 20) {
            SeatLegend(color: .blue, text: "Selected")
            SeatLegend(color: .gray, text: "Unavailable")
            SeatLegend(color: .green, text: "Available")
        }
        .padding(.top, 10)
    }
}

struct SeatLegend: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .frame(width: 12, height: 12)
                .foregroundColor(color)
            Text(text)
                .font(.caption)
        }
    }
}