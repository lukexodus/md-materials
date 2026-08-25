## Overview

class IOrderRepository(ABC):
    """Repository interface for order persistence"""
    
    @abstractmethod
    def get_by_id(self, order_id: str) -> Optional[Order]:
        """Retrieve order by ID"""
        pass
    
    @abstractmethod
    def get_by_customer(self, customer_id: str) -> List[Order]:
        """Get all orders for a customer"""
        pass
    
    @abstractmethod
    def save(self, order: Order) -> None:
        """Persist order changes"""
        pass
    
    @abstractmethod
    def next_identity(self) -> str:
        """Generate next order ID"""
        pass

class IInventoryRepository(ABC):
    """Repository interface for inventory management"""
    
    @abstractmethod
    def check_availability(self, product_id: str, quantity: int) -> bool:
        """Check if product quantity is available"""
        pass
    
    @abstractmethod
    def reserve(self, product_id: str, quantity: int) -> bool:
        """Reserve inventory for order"""
        pass
    
    @abstractmethod
    def release(self, product_id: str, quantity: int) -> None:
        """Release reserved inventory"""
        pass

