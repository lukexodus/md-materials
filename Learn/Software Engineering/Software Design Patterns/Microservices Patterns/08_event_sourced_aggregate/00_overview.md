## Overview

class Order:
    def __init__(self, order_id: str = None):
        self.id = order_id or str(uuid.uuid4())
        self.customer_id = None
        self.items = []
        self.status = OrderStatus.DRAFT
        self.total = 0.0
        self.shipping_address = None
        self.uncommitted_events = []
    
    def place_order(self, customer_id: str, items: List[dict], shipping_address: dict):
        """Execute business logic and produce events"""
        if not items:
            raise ValueError("Order must contain items")
        
        if self.status != OrderStatus.DRAFT:
            raise ValueError("Order already placed")
        
        # Calculate total
        total = sum(item['price'] * item['quantity'] for item in items)
        
        # Produce event
        event = OrderPlacedEvent(
            event_id=str(uuid.uuid4()),
            order_id=self.id,
            customer_id=customer_id,
            items=items,
            total=total,
            shipping_address=shipping_address,
            timestamp=datetime.now()
        )
        
        # Apply event to self
        self._apply_event(event)
        
        # Track for persistence
        self.uncommitted_events.append(event)
    
    def cancel_order(self, reason: str):
        """Cancel order with business rules"""
        if self.status == OrderStatus.DELIVERED:
            raise ValueError("Cannot cancel delivered order")
        
        event = OrderCancelledEvent(
            event_id=str(uuid.uuid4()),
            order_id=self.id,
            reason=reason,
            timestamp=datetime.now()
        )
        
        self._apply_event(event)
        self.uncommitted_events.append(event)
    
    def _apply_event(self, event):
        """Apply event to update aggregate state"""
        if isinstance(event, OrderPlacedEvent):
            self.customer_id = event.customer_id
            self.items = event.items
            self.total = event.total
            self.shipping_address = event.shipping_address
            self.status = OrderStatus.PLACED
        
        elif isinstance(event, OrderCancelledEvent):
            self.status = OrderStatus.CANCELLED
    
    @classmethod
    def from_events(cls, events: List):
        """Reconstitute aggregate from event history"""
        order = cls()
        for event in events:
            order._apply_event(event)
        return order

