## Overview


def main():
    print("=" * 80)
    print("APPLICATION SERVICE PATTERN DEMONSTRATION")
    print("=" * 80)

    # Initialize infrastructure
    order_repo = InMemoryOrderRepository()
    inventory_repo = InMemoryInventoryRepository()
    payment_gateway = MockPaymentGateway()
    notification_service = MockNotificationService()

    # Initialize application service
    order_service = OrderApplicationService(
        order_repo,
        inventory_repo,
        payment_gateway,
        notification_service,
    )

    print("\n" + "=" * 80)
    print("USE CASE 1: Create Order")
    print("=" * 80)

    create_command = CreateOrderCommand(
        customer_id="CUST-12345",
        items=[
            {
                "product_id": "PROD-001",
                "product_name": "Laptop Computer",
                "unit_price": "1299.99",
                "quantity": 1,
            },
            {
                "product_id": "PROD-002",
                "product_name": "Wireless Mouse",
                "unit_price": "49.99",
                "quantity": 2,
            },
        ],
        shipping_address={
            "street": "123 Main Street",
            "city": "San Francisco",
            "state": "CA",
            "postal_code": "94105",
            "country": "USA",
        },
        payment_method="credit_card",
    )

    result = order_service.create_order(create_command)

    if result.success:
        print("\n✓ Order created successfully")
        order_dto = result.data
        order_id = order_dto.order_id
        print(f"  Order ID: {order_dto.order_id}")
        print(f"  Status: {order_dto.status}")
        print(f"  Total: {order_dto.total}")
    else:
        print(f"\n✗ Order creation failed: {result.error}")
        if result.errors:
            for error in result.errors:
                print(f"  - {error}")
        return

    print("\n" + "=" * 80)
    print("USE CASE 2: Process Payment and Confirm Order")
    print("=" * 80)

    result = order_service.process_payment_and_confirm(
        order_id, "credit_card"
    )

    if result.success:
        print("\n✓ Payment processed and order confirmed")
        order_dto = result.data
        print(f"  Order ID: {order_dto.order_id}")
        print(f"  Status: {order_dto.status}")
        print(f"  Payment Status: {order_dto.payment_status}")
    else:
        print(f"\n✗ Payment processing failed: {result.error}")

    print("\n" + "=" * 80)
    print("USE CASE 3: Ship Order")
    print("=" * 80)

    result = order_service.ship_order(order_id, "TRACK-123456789")

    if result.success:
        print("\n✓ Order shipped successfully")
        order_dto = result.data
        print(f"  Order ID: {order_dto.order_id}")
        print(f"  Status: {order_dto.status}")
    else:
        print(f"\n✗ Shipping failed: {result.error}")

    print("\n" + "=" * 80)
    print("USE CASE 4: Create Second Order")
    print("=" * 80)

    create_command2 = CreateOrderCommand(
        customer_id="CUST-12345",
        items=[
            {
                "product_id": "PROD-003",
                "product_name": "Mechanical Keyboard",
                "unit_price": "159.99",
                "quantity": 1,
            }
        ],
        shipping_address={
            "street": "123 Main Street",
            "city": "San Francisco",
            "state": "CA",
            "postal_code": "94105",
            "country": "USA",
        },
        payment_method="credit_card",
    )

    result = order_service.create_order(create_command2)

    if result.success:
        print("\n✓ Second order created successfully")
        order_id_2 = result.data.order_id
        print(f"  Order ID: {order_id_2}")

    print("\n" + "=" * 80)
    print("USE CASE 5: Cancel Order")
    print("=" * 80)

    result = order_service.cancel_order(
        order_id_2, "Customer requested cancellation"
    )

    if result.success:
        print("\n✓ Order cancelled successfully")
        order_dto = result.data
        print(f"  Order ID: {order_dto.order_id}")
        print(f"  Status: {order_dto.status}")
    else:
        print(f"\n✗ Cancellation failed: {result.error}")

    print("\n" + "=" * 80)
    print("USE CASE 6: Get Customer Orders")
    print("=" * 80)

    result = order_service.get_customer_orders("CUST-12345")

    if result.success:
        orders = result.data
        print(f"\n✓ Retrieved {len(orders)} orders for customer CUST-12345")
        for order_dto in orders:
            print(f"\n  Order {order_dto.order_id}:")
            print(f"    Status: {order_dto.status}")
            print(f"    Total: {order_dto.total}")
            print(f"    Items: {len(order_dto.items)}")
            print(f"    Created: {order_dto.created_at}")

    print("\n" + "=" * 80)
    print("DEMONSTRATION OF DOMAIN RULE ENFORCEMENT")
    print("=" * 80)

    print("\nAttempting to ship already-shipped order...")
    result = order_service.ship_order(order_id, "TRACK-987654321")

    if not result.success:
        print(f"✓ Domain rule enforced: {result.error}")

    print("\nAttempting to create order without shipping address...")
    invalid_command = CreateOrderCommand(
        customer_id="CUST-99999",
        items=[
            {
                "product_id": "PROD-001",
                "product_name": "Test",
                "unit_price": "100",
                "quantity": 1,
            }
        ],
        shipping_address={},
        payment_method="credit_card",
    )

    result = order_service.create_order(invalid_command)

    if not result.success:
        print("✓ Validation enforced:")
        for error in result.errors or []:
            print(f"  - {error}")

    print("\n" + "=" * 80)
    print("DEMONSTRATION COMPLETE")
    print("=" * 80)


if __name__ == "__main__":
    main()
```

### **Output**

```

