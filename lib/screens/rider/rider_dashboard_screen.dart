import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../auth/signin_screen.dart';
import '../../services/auth_service.dart';

class RiderDashboardScreen extends StatefulWidget {
  const RiderDashboardScreen({Key? key}) : super(key: key);

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {...doc.data(), 'docId': doc.id})
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders();
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Accepted':
        return Colors.blue;
      case 'On the Way':
        return Colors.orange;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showStatusOptions(
    BuildContext context,
    String docId,
    String currentStatus,
  ) {
    final List<String> statusOptions = [
      'Accepted',
      'On the Way',
      'Delivered',
      'Cancelled',
    ];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusOptions.map((status) {
              final isSelected = status == currentStatus;
              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: _getStatusColor(status),
                ),
                title: Text(status),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(docId)
                        .update({'status': status});
                    setState(() {
                      _ordersFuture = fetchOrders();
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update status: $e')),
                    );
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Rider Dashboard',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                setState(() => _ordersFuture = fetchOrders());
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await AuthService().signOut();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.green),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No orders available.'));
            }

            final orders = snapshot.data!;
            return ListView.separated(
              padding: EdgeInsets.all(padding),
              itemCount: orders.length,
              separatorBuilder: (_, __) => SizedBox(height: padding * 0.5),
              itemBuilder: (context, index) {
                final order = orders[index];
                final String docId = order['docId'] ?? '';
                final String status = order['status'] ?? 'Pending';

                return GestureDetector(
                  onTap: () => _showStatusOptions(context, docId, status),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(padding * 0.5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID: ${order['orderId']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('Name: ${order['name']}'),
                          Text('Phone: ${order['phone']}'),
                          Text('Address: ${order['address']}'),
                          Text('Total: ${order['total']}'),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text(
                                'Status: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Chip(
                                label: Text(status),
                                backgroundColor: _getStatusColor(
                                  status,
                                ).withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (order['items'] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Items:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                ...List.from(order['items']).map(
                                  (item) => Text(
                                    '- ${item['name']} (${item['weight']}) x${item['quantity']}',
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
