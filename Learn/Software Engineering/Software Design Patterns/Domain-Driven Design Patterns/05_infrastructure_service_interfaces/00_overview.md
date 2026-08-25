## Overview

class IPaymentGateway(ABC):
    """Payment processing service interface"""
    
    @abstractmethod
    def authorize(self, order_id: str, amount: Money, 
                 payment_method: str) -> Dict[str, Any]:
        """Authorize payment"""
        pass
    
    @abstractmethod
    def capture(self, authorization_id: str) -> Dict[str, Any]:
        """Capture authorized payment"""
        pass
    
    @abstractmethod
    def refund(self, transaction_id: str, amount: Money) -> Dict[str, Any]:
        """Refund payment"""
        pass

class INotificationService(ABC):
    """Notification service interface"""
    
    @abstractmethod
    def send_order_confirmation(self, customer_id: str, order_id: str) -> None:
        """Send order confirmation notification"""
        pass
    
    @abstractmethod
    def send_shipping_notification(self, customer_id: str, 
                                   order_id: str, tracking_number: str) -> None:
        """Send shipping notification"""
        pass

