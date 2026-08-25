## Overview


class InMemoryOrderRepository(IOrderRepository):
    """In-memory order repository for demonstration"""

    def __init__(self):
        self._orders: Dict[str, Order] = {}
        self._counter = 0

    def get_by_id(self, order_id: str) -> Optional[Order]:
        return self._orders.get(order_id)

    def get_by_customer(self, customer_id: str) -> List[Order]:
        return [o for o in self._orders.values() if o.customer_id == customer_id]

    def save(self, order: Order) -> None:
        self._orders[order.order_id] = order
        print(f"[REPOSITORY] Saved order {order.order_id}")

    def next_identity(self) -> str:
        self._counter += 1
        return f"ORD-{self._counter:05d}"


class InMemoryInventoryRepository(IInventoryRepository):
    """In-memory inventory repository for demonstration"""

    def __init__(self):
        self._inventory = {
            "PROD-001": 100,
            "PROD-002": 50,
            "PROD-003": 25,
        }
        self._reserved = {}

    def check_availability(self, product_id: str, quantity: int) -> bool:
        available = self._inventory.get(product_id, 0)
        reserved = self._reserved.get(product_id, 0)
        result = (available - reserved) >= quantity
        print(
            f"[INVENTORY] Check {product_id}: "
            f"available={available}, reserved={reserved}, "
            f"need={quantity}, ok={result}"
        )
        return result

    def reserve(self, product_id: str, quantity: int) -> bool:
        if not self.check_availability(product_id, quantity):
            return False

        self._reserved[product_id] = self._reserved.get(product_id, 0) + quantity
        print(f"[INVENTORY] Reserved {quantity} of {product_id}")
        return True

    def release(self, product_id: str, quantity: int) -> None:
        self._reserved[product_id] = max(
            0, self._reserved.get(product_id, 0) - quantity
        )
        print(f"[INVENTORY] Released {quantity} of {product_id}")


class MockPaymentGateway(IPaymentGateway):
    """Mock payment gateway for demonstration"""

    def authorize(
        self,
        order_id: str,
        amount: Money,
        payment_method: str,
    ) -> Dict[str, Any]:
        auth_id = f"AUTH-{uuid4().hex[:8].upper()}"
        print(f"[PAYMENT] Authorized {amount} for order {order_id}")
        print(f"  Authorization ID: {auth_id}")
        return {
            "success": True,
            "authorization_id": auth_id,
            "amount": str(amount),
        }

    def capture(self, authorization_id: str) -> Dict[str, Any]:
        transaction_id = f"TXN-{uuid4().hex[:8].upper()}"
        print(f"[PAYMENT] Captured payment {authorization_id}")
        print(f"  Transaction ID: {transaction_id}")
        return {
            "success": True,
            "transaction_id": transaction_id,
        }

    def refund(self, transaction_id: str, amount: Money) -> Dict[str, Any]:
        refund_id = f"REF-{uuid4().hex[:8].upper()}"
        print(f"[PAYMENT] Refunded {amount} for transaction {transaction_id}")
        print(f"  Refund ID: {refund_id}")
        return {
            "success": True,
            "refund_id": refund_id,
        }


class MockNotificationService(INotificationService):
    """Mock notification service for demonstration"""

    def send_order_confirmation(self, customer_id: str, order_id: str) -> None:
        print(f"[NOTIFICATION] Sent order confirmation to customer {customer_id}")
        print(f"  Order: {order_id}")

    def send_shipping_notification(
        self,
        customer_id: str,
        order_id: str,
        tracking_number: str,
    ) -> None:
        print(f"[NOTIFICATION] Sent shipping notification to customer {customer_id}")
        print(f"  Order: {order_id}, Tracking: {tracking_number}")


