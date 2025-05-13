import SwiftUI

struct BookingView: View {
    let venue: Venue
    @EnvironmentObject private var viewModel: BookingViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VenueHeader(venue: venue)
                    
                    DateSelectionView(selectedDate: $viewModel.selectedDate)
                    
                    TimeSlotPicker(
                        selectedTime: $viewModel.selectedTime,
                        timeSlots: venue.availableTimeSlots
                    )
                    
                    SeatMapView(
                        layout: venue.seatLayout,
                        selectedSeats: $viewModel.selectedSeats,
                        maxSelection: venue.maxSeatsPerBooking
                    )
                    
                    if let error = viewModel.errorMessage {
                        ErrorMessageView(message: error)
                    }
                    
                    Spacer()
                    
                    ConfirmButton(
                        isEnabled: !viewModel.selectedSeats.isEmpty && !viewModel.selectedTime.isEmpty,
                        action: { showingConfirmation = true }
                    )
                }
                .padding()
            }
            .navigationTitle("Booking Details")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Confirm Booking", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm") {
                    if viewModel.createBooking(userId: "user1", venue: venue) {
                        dismiss()
                    }
                }
            } message: {
                let seats = viewModel.selectedSeats.joined(separator: ", ")
                let total = venue.basePrice * Double(viewModel.selectedSeats.count)
                Text("You're booking seats \(seats) at \(viewModel.selectedTime)\nTotal: $\(total, specifier: "%.2f")")
            }
            .onDisappear {
                viewModel.selectedSeats = []
                viewModel.selectedTime = ""
                viewModel.errorMessage = nil
            }
        }
    }
}

struct VenueHeader: View {
    let venue: Venue
    
    var body: some View {
        VStack {
            Image(systemName: venue.type.icon)
                .font(.system(size: 50))
                .foregroundColor(.blue)
            Text(venue.name)
                .font(.title.bold())
            Text("Max \(venue.maxSeatsPerBooking) seats per booking")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct DateSelectionView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select Date")
                .font(.headline)
            
            DatePicker(
                "",
                selection: $selectedDate,
                in: Date()...Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
        }
    }
}

struct TimeSlotPicker: View {
    @Binding var selectedTime: String
    let timeSlots: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Select Time")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(timeSlots, id: \.self) { time in
                        Text(time)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selectedTime == time ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedTime == time ? .white : .primary)
                            .cornerRadius(8)
                            .onTapGesture {
                                selectedTime = time
                            }
                    }
                }
            }
        }
    }
}

struct ErrorMessageView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.1))
            .foregroundColor(.red)
            .cornerRadius(8)
    }
}

struct ConfirmButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Confirm Booking")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(!isEnabled)
    }
}