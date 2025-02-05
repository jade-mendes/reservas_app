import 'package:flutter/material.dart';
import 'package:reservas_app/models/booking.dart';
import 'package:reservas_app/models/property.dart';
import 'package:reservas_app/services/booking_service.dart';
import 'package:reservas_app/services/property_service.dart';

class BookingsScreen extends StatefulWidget {
  final int userId;

  const BookingsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingService _bookingService = BookingService();
  final PropertyService _propertyService = PropertyService();

  Future<List<BookingWithProperty>> _loadBookings() async {
    print(widget.userId);
    final bookings = await _bookingService.getBookingsByUserId(widget.userId);
    print(bookings.length);
    List<BookingWithProperty> bookingsWithProperties = [];

    for (var booking in bookings) {
      final property =
          await _propertyService.getPropertyById(booking.propertyId);
      if (property != null) {
        bookingsWithProperties.add(
          BookingWithProperty(booking: booking, property: property),
        );
      }
    }

    return bookingsWithProperties;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Reservas'),
      ),
      body: FutureBuilder<List<BookingWithProperty>>(
        future: _loadBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma reserva encontrada'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final bookingWithProperty = snapshot.data![index];
              return BookingCard(bookingWithProperty: bookingWithProperty);
            },
          );
        },
      ),
    );
  }
}

class BookingWithProperty {
  final Booking booking;
  final Property property;

  BookingWithProperty({
    required this.booking,
    required this.property,
  });
}

class BookingCard extends StatelessWidget {
  final BookingWithProperty bookingWithProperty;

  const BookingCard({
    Key? key,
    required this.bookingWithProperty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            child: Image.network(
              bookingWithProperty.property.thumbnail,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título da propriedade
                Text(
                  bookingWithProperty.property.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                // Datas de check-in e check-out
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Check-in: ${bookingWithProperty.booking.checkinDate}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Check-out: ${bookingWithProperty.booking.checkoutDate}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Preço total
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Total: R\$ ${bookingWithProperty.booking.totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
