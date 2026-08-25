## Overview

@dataclass
class OrderPlacedEvent:
    event_id: str
    order_id: str
    customer_id: str
    items: List[dict]
    total: float
    shipping_address: dict
    timestamp: datetime

@dataclass
class OrderCancelledEvent:
    event_id: str
    order_id: str
    reason: str
    timestamp: datetime

