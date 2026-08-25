## Overview

@dataclass(frozen=True)
class Money:
    """Value object representing monetary amounts"""
    amount: Decimal
    currency: str = "USD"
    
    def add(self, other: 'Money') -> 'Money':
        if self.currency != other.currency:
            raise ValueError("Cannot add money with different currencies")
        return Money(self.amount + other.amount, self.currency)
    
    def multiply(self, factor: int) -> 'Money':
        return Money(self.amount * factor, self.currency)
    
    def __str__(self) -> str:
        return f"{self.currency} {self.amount:.2f}"

@dataclass(frozen=True)
class Address:
    """Value object for shipping addresses"""
    street: str
    city: str
    state: str
    postal_code: str
    country: str
    
    def validate(self) -> List[str]:
        """Validate address completeness"""
        errors = []
        if not self.street:
            errors.append("Street address is required")
        if not self.city:
            errors.append("City is required")
        if not self.postal_code:
            errors.append("Postal code is required")
        return errors

