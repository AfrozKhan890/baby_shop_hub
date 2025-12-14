class AdminStats {
  final int totalProducts;
  final int totalOrders;
  final int totalUsers;
  final double totalRevenue;
  final List<DailyRevenue> weeklyRevenue;

  AdminStats({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalUsers,
    required this.totalRevenue,
    required this.weeklyRevenue,
  });
}

class DailyRevenue {
  final DateTime date;
  final double revenue;
  final int orders;

  DailyRevenue({
    required this.date,
    required this.revenue,
    required this.orders,
  });
}

class RecentOrder {
  final String id;
  final String customerName;
  final double amount;
  final DateTime date;
  final String status;

  RecentOrder({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.date,
    required this.status,
  });
}