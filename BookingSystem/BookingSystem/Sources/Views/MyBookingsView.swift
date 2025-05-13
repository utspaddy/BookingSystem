import SwiftUI

struct MyBookingsView: View {
    @EnvironmentObject private var viewModel: BookingViewModel
    @State private var showingCancelAlert = false
    @State private var bookingToCancel: Booking?
    
    var body: some View {
        NavigationStack {
            if viewModel.userBookings.isEmpty {
                EmptyStateView()
            } else {
                BookingListView(
                    bookings: viewModel.userBookings,
                    venues: viewModel.availableVenues,
                    onCancel: { booking in
                        bookingToCancel = booking
                        showingCancelAlert = true
                    }
                )
                .alert("Cancel Booking", isPresented: $showingCancelAlert) {
                    Button("No", role: .cancel) {}
                    Button("Yes", role: .destructive) {
                        if let booking = bookingToCancel {
                            _ = viewModel.cancelBooking(bookingId: booking.id)
                        }
                    }
                } message: {
                    Text("Are you sure you want to cancel this booking?")
                }
            }
        }
        .navigationTitle("My Bookings")
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding()
            Text("No bookings yet")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
}

struct BookingListView: View {
    let bookings: [Booking]
    let venues: [Venue]
    let onCancel: (Booking) -> Void
    
    var body: some View {
        List {
            ForEach(bookings) { booking in
                if let venue = venues.first(where: { $0.id == booking.venueId }) {
                    BookingCard(booking: booking, venue: venue)
                        .swipeActions(edge: .trailing) {
                            if booking.status == .confirmed {
                                Button(role: .destructive) {
                                    onCancel(booking)
                                } label: {
                                    Label("Cancel", systemImage: "trash")
                                }
                            }
                        }
                }
            }
        }
        .listStyle(.plain)
    }
}

struct BookingCard: View {
    let booking: Booking
    let venue: Venue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: venue.type.icon)
                    .foregroundColor(.blue)
                
                Text(venue.name)
                    .font(.headline)
                
                Spacer()
                
                StatusBadge(status: booking.status)
            }
            
            BookingDetailRow(icon: "calendar", text: booking.bookingDate.formatted(date: .abbreviated, time: .omitted))
            
            BookingDetailRow(icon: "clock", text: booking.bookingTime)
            
            if !booking.seatNumbers.isEmpty {
                BookingDetailRow(icon: "seat", text: "Seats: \(booking.seatNumbers.joined(separator: ", "))")
            }
            
            BookingDetailRow(icon: "dollarsign.circle", text: "Total: $\(booking.price, specifier: "%.2f")")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let status: BookingStatus
    
    var statusColor: Color {
        switch status {
        case .confirmed: return .green
        case .cancelled: return .red
        case .completed: return .blue
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
}

struct BookingDetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
            Text(text)
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}