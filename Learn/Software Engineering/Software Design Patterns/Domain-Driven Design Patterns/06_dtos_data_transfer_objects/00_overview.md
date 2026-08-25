## Overview

@dataclass
class CreateOrderCommand:
    """Command for creating new order"""
    customer_id: str
    items: List[Dict[str, Any]]  # [{'product_id': ..., 'quantity': ...}]
    shipping_address: Dict[str, str]
    payment_method: str

@dataclass
class OrderDto:
    """DTO for order data returned to clients"""
    order_id: str
    customer_id: str
    status: str
    total: str
    items: List[Dict[str, Any]]
    shipping_address: Optional[Dict[str, str]]
    created_at: str
    payment_status: str

@dataclass
class Result:
    """Generic result object for service responses"""
    success: bool
    data: Optional[Any] = None
    error: Optional[str] = None
    errors: Optional[List[str]] = None

