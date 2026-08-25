## Overview

class OrderLine:
    """Entity representing a line item in an order"""
    
    def __init__(self, product_id: str, product_name: str, 
                 unit_price: Money, quantity: int):
        if quantity <= 0:
            raise ValueError("Quantity must be positive")
        
        self.product_id = product_id
        self.product_name = product_name
        self.unit_price = unit_price
        self.quantity = quantity
    
    def subtotal(self) -> Money:
        """Calculate line item subtotal"""
        return self.unit_price.multiply(self.quantity)
    
    def __repr__(self) -> str:
        return f"OrderLine({self.product_name} x{self.quantity})"

class Order:
    """Aggregate root for order domain"""
    
    def __init__(self, order_id: str, customer_id: str):
        self.order_id = order_id
        self.customer_id = customer_id
        self.lines: List[OrderLine] = []
        self.status = OrderStatus.PENDING
        self.shipping_address: Optional[Address] = None
        self.created_at = datetime.utcnow()
        self.payment_status = PaymentStatus.PENDING
    
    def add_line(self, product_id: str, product_name: str, 
                 unit_price: Money, quantity: int):
        """Add product to order"""
        if self.status != OrderStatus.PENDING:
            raise ValueError(f"Cannot modify order in {self.status.value} status")
        
        line = OrderLine(product_id, product_name, unit_price, quantity)
        self.lines.append(line)
    
    def set_shipping_address(self, address: Address):
        """Set shipping address with validation"""
        errors = address.validate()
        if errors:
            raise ValueError(f"Invalid address: {', '.join(errors)}")
        
        self.shipping_address = address
    
    def calculate_total(self) -> Money:
        """Calculate order total"""
        if not self.lines:
            return Money(Decimal("0.00"))
        
        total = self.lines[0].subtotal()
        for line in self.lines[1:]:
            total = total.add(line.subtotal())
        
        return total
    
    def confirm(self):
        """Confirm order - domain business rule"""
        if self.status != OrderStatus.PENDING:
            raise ValueError(f"Cannot confirm order in {self.status.value} status")
        
        if not self.lines:
            raise ValueError("Cannot confirm empty order")
        
        if not self.shipping_address:
            raise ValueError("Cannot confirm order without shipping address")
        
        if self.payment_status != PaymentStatus.CAPTURED:
            raise ValueError("Cannot confirm order without successful payment")
        
        self.status = OrderStatus.CONFIRMED
    
    def cancel(self):
        """Cancel order - domain business rule"""
        if self.status in [OrderStatus.SHIPPED, OrderStatus.DELIVERED]:
            raise ValueError(f"Cannot cancel order in {self.status.value} status")
        
        self.status = OrderStatus.CANCELLED
    
    def mark_as_shipped(self, tracking_number: str):
        """Mark order as shipped"""
        if self.status != OrderStatus.CONFIRMED:
            raise ValueError(f"Cannot ship order in {self.status.value} status")
        
        self.status = OrderStatus.SHIPPED
        self.tracking_number = tracking_number
    
    def authorize_payment(self):
        """Authorize payment"""
        if self.payment_status != PaymentStatus.PENDING:
            raise ValueError(f"Cannot authorize payment in {self.payment_status.value} status")
        
        self.payment_status = PaymentStatus.AUTHORIZED
    
    def capture_payment(self):
        """Capture payment"""
        if self.payment_status != PaymentStatus.AUTHORIZED:
            raise ValueError(f"Cannot capture payment in {self.payment_status.value} status")
        
        self.payment_status = PaymentStatus.CAPTURED
    
    def __repr__(self) -> str:
        return f"Order({self.order_id}, status={self.status.value}, lines={len(self.lines)})"

