// mock_data_repository.dart

class MockDataRepository {
  static final List<Map<String, dynamic>> mockOrders = [
    {
      "id": 1,
      "order_number": "ORD001",
      "customer_name": "John Doe",
      "total_amount": 150000,
      "status": "Pending",
      "created_at": "2024-03-25T10:30:00Z",
      "items": [
        {
          "name": "T-Shirt",
          "quantity": 2,
          "price": 75000
        }
      ]
    },
    {
      "id": 2,
      "order_number": "ORD002",
      "customer_name": "Jane Smith",
      "total_amount": 200000,
      "status": "Processing",
      "created_at": "2024-03-25T11:00:00Z",
      "items": [
        {
          "name": "Pants",
          "quantity": 1,
          "price": 200000
        }
      ]
    },
    {
      "id": 3,
      "order_number": "ORD003",
      "customer_name": "Mike Johnson",
      "total_amount": 300000,
      "status": "Completed",
      "created_at": "2024-03-25T09:00:00Z",
      "items": [
        {
          "name": "Jacket",
          "quantity": 1,
          "price": 300000
        }
      ]
    }
  ];

  static final List<Map<String, dynamic>> mockStatusWiseOrders = [
    {
      "status": "Pending",
      "count": 10
    },
    {
      "status": "Processing",
      "count": 5
    },
    {
      "status": "Completed",
      "count": 15
    },
    {
      "status": "Cancelled",
      "count": 2
    },
    {
      "status": "Delivered",
      "count": 8
    }
  ];

  static Map<String, dynamic> mockOrderDetails = {
    "id": 1,
    "order_number": "ORD001",
    "customer_name": "John Doe",
    "customer_phone": "+84123456789",
    "customer_address": "123 Main St, City",
    "total_amount": 150000,
    "status": "Pending",
    "created_at": "2024-03-25T10:30:00Z",
    "items": [
      {
        "name": "T-Shirt",
        "quantity": 2,
        "price": 75000,
        "subtotal": 150000
      }
    ],
    "notes": "Please handle with care"
  };
}
// mock_dashboard_data.dart

class MockDashboardData {
  static final dashboardInfo = {
    "today_orders": 15,
    "today_earning": "\$1,250.00",
    "this_month_earnings": "\$28,350.00",
    "processing_orders": 8,
    "orders": [
      {
        "id": 1,
        "order_code": "ORD-001",
        "payable_amount": 125.50,
        "order_status": "Pending",
        "payment_type": "Credit Card",
        "payment_status": "Paid",
        "pick_date": "2024-10-26",
        "delivery_date": "2024-10-28",
        "ordered_at": "2024-10-26 09:30:00",
        "items": 3,
        "user_name": "John Doe",
        "user_mobile": "+1234567890",
        "user_profile": "https://example.com/profile1.jpg",
        "address": "123 Main St, City, Country",
        "products": [
          {
            "service_name": "Regular Wash",
            "items": [
              {
                "quantity": 2,
                "name": "T-Shirt"
              },
              {
                "quantity": 1,
                "name": "Pants"
              }
            ]
          }
        ],
        "invoice_path": "/invoices/001.pdf"
      },
      {
        "id": 2,
        "order_code": "ORD-002",
        "payable_amount": 85.75,
        "order_status": "Processing",
        "payment_type": "Cash",
        "payment_status": "Pending",
        "pick_date": "2024-10-26",
        "delivery_date": "2024-10-29",
        "ordered_at": "2024-10-26 10:15:00",
        "items": 2,
        "user_name": "Jane Smith",
        "user_mobile": "+1987654321",
        "user_profile": "https://example.com/profile2.jpg",
        "address": "456 Oak St, City, Country",
        "products": [
          {
            "service_name": "Dry Clean",
            "items": [
              {
                "quantity": 1,
                "name": "Suit"
              },
              {
                "quantity": 1,
                "name": "Dress"
              }
            ]
          }
        ],
        "invoice_path": "/invoices/002.pdf"
      }
    ]
  };

  static final statusWiseOrderCount = [
    {
      "status": "Pending",
      "count": 5
    },
    {
      "status": "Processing",
      "count": 3
    },
    {
      "status": "Ready",
      "count": 2
    },
    {
      "status": "Completed",
      "count": 8
    },
    {
      "status": "Cancelled",
      "count": 1
    }
  ];
}