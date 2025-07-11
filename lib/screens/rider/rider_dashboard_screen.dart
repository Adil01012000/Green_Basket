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
  bool _isRefreshing = false;

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data(), 'docId': doc.id})
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching orders: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return [];
    }
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
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Update Order Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(height: 1),
                  ...statusOptions.map((status) {
                    final isSelected = status == currentStatus;
                    return ListTile(
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: _getStatusColor(status),
                      ),
                      title: Text(
                        status,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(docId)
                              .update({'status': status});
                          if (mounted) {
                            setState(() {
                              _ordersFuture = fetchOrders();
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update status: $e'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Accepted':
        return Icons.check_circle_outline;
      case 'On the Way':
        return Icons.directions_bike;
      case 'Delivered':
        return Icons.done_all;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  Future<void> _refreshOrders() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _ordersFuture = fetchOrders();
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = isTablet ? screenWidth * 0.05 : screenWidth * 0.04;
    final maxContentWidth = isTablet ? 800.0 : double.infinity;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
          title: Text(
            'Rider Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
                size: isTablet ? 30 : 24,
              ),
              onPressed: _refreshOrders,
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
                size: isTablet ? 30 : 24,
              ),
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
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: RefreshIndicator(
              onRefresh: _refreshOrders,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !_isRefreshing) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No orders available',
                            style: TextStyle(
                              fontSize: isTablet ? 22 : 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: _refreshOrders,
                            child: Text(
                              'Refresh',
                              style: TextStyle(fontSize: isTablet ? 18 : 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final orders = snapshot.data!;
                  return ListView.separated(
                    padding: EdgeInsets.all(padding),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: padding * 0.8),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final String docId = order['docId'] ?? '';
                      final String status = order['status'] ?? 'Pending';

                      return GestureDetector(
                        onTap: () => _showStatusOptions(context, docId, status),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(padding * 0.5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order ID: ${order['orderId']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTablet ? 20 : 16,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 14,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(status),
                                        ),
                                      ),
                                      backgroundColor: _getStatusColor(
                                        status,
                                      ).withOpacity(0.1),
                                      shape: StadiumBorder(
                                        side: BorderSide(
                                          color: _getStatusColor(status),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isTablet ? 12 : 8),
                                _buildInfoRow(
                                  'Customer:',
                                  '${order['name']}',
                                  isTablet: isTablet,
                                ),
                                _buildInfoRow(
                                  'Phone:',
                                  '${order['phone']}',
                                  isTablet: isTablet,
                                ),
                                _buildInfoRow(
                                  'Address:',
                                  '${order['address']}',
                                  isTablet: isTablet,
                                ),
                                _buildInfoRow(
                                  'Total:',
                                  '${order['total']}',
                                  isTablet: isTablet,
                                ),
                                SizedBox(height: isTablet ? 12 : 8),
                                if (order['items'] != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Items:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isTablet ? 18 : 16,
                                        ),
                                      ),
                                      SizedBox(height: isTablet ? 8 : 4),
                                      ...List.from(order['items']).map(
                                        (item) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: isTablet ? 6 : 4,
                                          ),
                                          child: Text(
                                            '• ${item['name']} (${item['weight']}) x${item['quantity']}',
                                            style: TextStyle(
                                              fontSize: isTablet ? 16 : 14,
                                            ),
                                          ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {required bool isTablet}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 8 : 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: isTablet ? 18 : 14, color: Colors.black),
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
