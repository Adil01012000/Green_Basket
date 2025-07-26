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

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;
  static const double _desktopBreakpoint = 1440;

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < _mobileBreakpoint;
  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _mobileBreakpoint &&
      MediaQuery.of(context).size.width < _tabletBreakpoint;
  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= _desktopBreakpoint;

  double _getMaxContentWidth(BuildContext context) {
    if (_isMobile(context)) return double.infinity;
    if (_isTablet(context)) return 800.0;
    if (_isDesktop(context)) return 1000.0;
    return 900.0;
  }

  double _getPadding(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 28.0;
    if (_isDesktop(context)) return 40.0;
    return 20.0;
  }

  double _getHeaderFontSize(BuildContext context) {
    if (_isMobile(context)) return 20.0;
    if (_isTablet(context)) return 24.0;
    if (_isDesktop(context)) return 28.0;
    return 22.0;
  }

  double _getCardRadius(BuildContext context) {
    if (_isMobile(context)) return 12.0;
    if (_isTablet(context)) return 18.0;
    if (_isDesktop(context)) return 24.0;
    return 16.0;
  }

  double _getCardPadding(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 24.0;
    if (_isDesktop(context)) return 32.0;
    return 20.0;
  }

  double _getChipFontSize(BuildContext context) {
    if (_isMobile(context)) return 14.0;
    if (_isTablet(context)) return 16.0;
    if (_isDesktop(context)) return 18.0;
    return 15.0;
  }

  double _getOrderIdFontSize(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 20.0;
    if (_isDesktop(context)) return 22.0;
    return 18.0;
  }

  double _getInfoFontSize(BuildContext context) {
    if (_isMobile(context)) return 14.0;
    if (_isTablet(context)) return 18.0;
    if (_isDesktop(context)) return 20.0;
    return 16.0;
  }

  double _getItemFontSize(BuildContext context) {
    if (_isMobile(context)) return 14.0;
    if (_isTablet(context)) return 16.0;
    if (_isDesktop(context)) return 18.0;
    return 15.0;
  }

  double _getIconSize(BuildContext context) {
    if (_isMobile(context)) return 24.0;
    if (_isTablet(context)) return 30.0;
    if (_isDesktop(context)) return 36.0;
    return 26.0;
  }

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_getCardRadius(context)),
        ),
      ),
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
                        fontSize: _getHeaderFontSize(context),
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
                        size: _getIconSize(context),
                      ),
                      title: Text(
                        status,
                        style: TextStyle(
                          fontSize: _getInfoFontSize(context),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                        size: _getIconSize(context),
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
    final maxContentWidth = _getMaxContentWidth(context);
    final padding = _getPadding(context);
    final headerFontSize = _getHeaderFontSize(context);
    final cardRadius = _getCardRadius(context);
    final cardPadding = _getCardPadding(context);
    final chipFontSize = _getChipFontSize(context);
    final orderIdFontSize = _getOrderIdFontSize(context);
    final infoFontSize = _getInfoFontSize(context);
    final itemFontSize = _getItemFontSize(context);
    final iconSize = _getIconSize(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
          title: Text(
            'Rider Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: headerFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white, size: iconSize),
              onPressed: _refreshOrders,
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white, size: iconSize),
              onPressed: () async {
                await AuthService().signOut();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                );
              },
              tooltip: 'Logout',
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
                            size: iconSize * 2.5,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: padding),
                          Text(
                            'No orders available',
                            style: TextStyle(
                              fontSize: headerFontSize,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: padding * 0.5),
                          TextButton(
                            onPressed: _refreshOrders,
                            child: Text(
                              'Refresh',
                              style: TextStyle(fontSize: infoFontSize),
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
                            borderRadius: BorderRadius.circular(cardRadius),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(cardPadding),
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
                                        fontSize: orderIdFontSize,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: chipFontSize,
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
                                SizedBox(height: padding * 0.5),
                                _buildInfoRow(
                                  'Customer:',
                                  '${order['name']}',
                                  fontSize: infoFontSize,
                                  padding: padding,
                                ),
                                _buildInfoRow(
                                  'Phone:',
                                  '${order['phone']}',
                                  fontSize: infoFontSize,
                                  padding: padding,
                                ),
                                _buildInfoRow(
                                  'Address:',
                                  '${order['address']}',
                                  fontSize: infoFontSize,
                                  padding: padding,
                                ),
                                _buildInfoRow(
                                  'Total:',
                                  '${order['total']}',
                                  fontSize: infoFontSize,
                                  padding: padding,
                                ),
                                SizedBox(height: padding * 0.5),
                                if (order['items'] != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Items:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: infoFontSize,
                                        ),
                                      ),
                                      SizedBox(height: padding * 0.3),
                                      ...List.from(order['items']).map(
                                        (item) => Padding(
                                          padding: EdgeInsets.only(
                                            bottom: padding * 0.2,
                                          ),
                                          child: Text(
                                            '• ${item['name']} (${item['weight']}) x${item['quantity']}',
                                            style: TextStyle(
                                              fontSize: itemFontSize,
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

  Widget _buildInfoRow(
    String label,
    String value, {
    required double fontSize,
    required double padding,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding * 0.3),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: fontSize, color: Colors.black),
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
