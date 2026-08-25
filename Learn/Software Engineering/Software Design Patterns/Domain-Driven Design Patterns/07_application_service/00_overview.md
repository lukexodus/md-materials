## Overview

class OrderApplicationService:
    """Application service coordinating order use cases"""
    
    def __init__(self, 
                 order_repository: IOrderRepository,
                 inventory_repository: IInventoryRepository,
                 payment_gateway: IPaymentGateway,
                 notification_service: INotificationService):
        self._order_repository = order_repository
        self._inventory_repository = inventory_repository
        self._payment_gateway = payment_gateway
        self._notification_service = notification_service
    
    def create_order(self, command: CreateOrderCommand) -> Result:
        """
        Create new order use case
        Coordinates: validation, inventory check, order creation, persistence
        """
        try:
            # Application-level validation
            validation_errors = self._validate_create_order(command)
            if validation_errors:
                return Result(success=False, errors=validation_errors)
            
            # Check inventory availability for all items
            for item in command.items:
                available = self._inventory_repository.check_availability(
                    item['product_id'], 
                    item['quantity']
                )
                if not available:
                    return Result(
                        success=False, 
                        error=f"Product {item['product_id']} not available in requested quantity"
                    )
            
            # Create order aggregate
            order_id = self._order_repository.next_identity()
            order = Order(order_id, command.customer_id)
            
            # Add order lines
            for item in command.items:
                order.add_line(
                    product_id=item['product_id'],
                    product_name=item['product_name'],
                    unit_price=Money(Decimal(str(item['unit_price']))),
                    quantity=item['quantity']
                )
            
            # Set shipping address (domain validation happens here)
            address = Address(
                street=command.shipping_address['street'],
                city=command.shipping_address['city'],
                state=command.shipping_address['state'],
                postal_code=command.shipping_address['postal_code'],
                country=command.shipping_address['country']
            )
            order.set_shipping_address(address)
            
            # Reserve inventory
            for item in command.items:
                self._inventory_repository.reserve(
                    item['product_id'], 
                    item['quantity']
                )
            
            # Persist order (transaction boundary)
            self._order_repository.save(order)
            
            # Return DTO
            order_dto = self._map_to_dto(order)
            
            print(f"\n[SERVICE] Order created: {order_id}")
            print(f"  Customer: {command.customer_id}")
            print(f"  Total: {order.calculate_total()}")
            print(f"  Items: {len(order.lines)}")
            
            return Result(success=True, data=order_dto)
            
        except ValueError as e:
            # Domain validation error
            return Result(success=False, error=str(e))
        except Exception as e:
            # Unexpected error
            print(f"[SERVICE] Error creating order: {e}")
            return Result(success=False, error="Failed to create order")
    
    def process_payment_and_confirm(self, order_id: str, 
                                    payment_method: str) -> Result:
        """
        Process payment and confirm order use case
        Coordinates: order retrieval, payment processing, order confirmation, notification
        """
        try:
            # Retrieve order aggregate
            order = self._order_repository.get_by_id(order_id)
            if not order:
                return Result(success=False, error="Order not found")
            
            # Calculate amount
            total = order.calculate_total()
            
            # Process payment through payment gateway
            print(f"\n[SERVICE] Processing payment for order {order_id}")
            print(f"  Amount: {total}")
            
            # Authorize payment
            auth_result = self._payment_gateway.authorize(
                order_id, 
                total, 
                payment_method
            )
            
            if not auth_result['success']:
                return Result(success=False, error="Payment authorization failed")
            
            order.authorize_payment()
            
            # Capture payment
            capture_result = self._payment_gateway.capture(
                auth_result['authorization_id']
            )
            
            if not capture_result['success']:
                return Result(success=False, error="Payment capture failed")
            
            order.capture_payment()
            
            # Confirm order (domain business rule enforcement)
            order.confirm()
            
            # Persist changes (transaction boundary)
            self._order_repository.save(order)
            
            # Send notification (outside transaction)
            self._notification_service.send_order_confirmation(
                order.customer_id,
                order.order_id
            )
            
            print(f"[SERVICE] Order confirmed: {order_id}")
            
            order_dto = self._map_to_dto(order)
            return Result(success=True, data=order_dto)
            
        except ValueError as e:
            return Result(success=False, error=str(e))
        except Exception as e:
            print(f"[SERVICE] Error processing payment: {e}")
            return Result(success=False, error="Failed to process payment")
    
    def cancel_order(self, order_id: str, reason: str) -> Result:
        """
        Cancel order use case
        Coordinates: order retrieval, cancellation, inventory release, refund
        """
        try:
            # Retrieve order
            order = self._order_repository.get_by_id(order_id)
            if not order:
                return Result(success=False, error="Order not found")
            
            print(f"\n[SERVICE] Cancelling order {order_id}")
            print(f"  Reason: {reason}")
            
            # Cancel order (domain rule enforcement)
            order.cancel()
            
            # Release inventory
            for line in order.lines:
                self._inventory_repository.release(
                    line.product_id, 
                    line.quantity
                )
            
            # Process refund if payment was captured
            if order.payment_status == PaymentStatus.CAPTURED:
                self._payment_gateway.refund(
                    order_id, 
                    order.calculate_total()
                )
            
            # Persist changes
            self._order_repository.save(order)
            
            print(f"[SERVICE] Order cancelled: {order_id}")
            
            order_dto = self._map_to_dto(order)
            return Result(success=True, data=order_dto)
            
        except ValueError as e:
            return Result(success=False, error=str(e))
        except Exception as e:
            print(f"[SERVICE] Error cancelling order: {e}")
            return Result(success=False, error="Failed to cancel order")
    
    def ship_order(self, order_id: str, tracking_number: str) -> Result:
        """
        Ship order use case
        Coordinates: order retrieval, shipping, notification
        """
        try:
            order = self._order_repository.get_by_id(order_id)
            if not order:
                return Result(success=False, error="Order not found")
            
            print(f"\n[SERVICE] Shipping order {order_id}")
            print(f"  Tracking: {tracking_number}")
            
            # Mark as shipped (domain rule enforcement)
            order.mark_as_shipped(tracking_number)
            
            # Persist changes
            self._order_repository.save(order)
            
            # Send notification
            self._notification_service.send_shipping_notification(
                order.customer_id,
                order.order_id,
                tracking_number
            )
            
            print(f"[SERVICE] Order shipped: {order_id}")
            
            order_dto = self._map_to_dto(order)
            return Result(success=True, data=order_dto)
            
        except ValueError as e:
            return Result(success=False, error=str(e))
        except Exception as e:
            print(f"[SERVICE] Error shipping order: {e}")
            return Result(success=False, error="Failed to ship order")
    
    def get_order(self, order_id: str) -> Result:
        """
        Get order details use case
        Simple retrieval and DTO mapping
        """
        try:
            order = self._order_repository.get_by_id(order_id)
            if not order:
                return Result(success=False, error="Order not found")
            
            order_dto = self._map_to_dto(order)
            return Result(success=True, data=order_dto)
            
        except Exception as e:
            print(f"[SERVICE] Error retrieving order: {e}")
            return Result(success=False, error="Failed to retrieve order")
    
    def get_customer_orders(self, customer_id: str) -> Result:
        """
        Get all orders for customer use case
        """
        try:
            orders = self._order_repository.get_by_customer(customer_id)
            order_dtos = [self._map_to_dto(order) for order in orders]
            
            return Result(success=True, data=order_dtos)
            
        except Exception as e:
            print(f"[SERVICE] Error retrieving customer orders: {e}")
            return Result(success=False, error="Failed to retrieve orders")
    
    def _validate_create_order(self, command: CreateOrderCommand) -> List[str]:
        """Application-level validation"""
        errors = []
        
        if not command.customer_id:
            errors.append("Customer ID is required")
        
        if not command.items:
            errors.append("Order must contain at least one item")

	    for item in command.items:
	        if 'product_id' not in item:
	            errors.append("Product ID required for all items")
	        if 'quantity' not in item or item['quantity'] <= 0:
	            errors.append("Valid quantity required for all items")
	    
	    required_address_fields = ['street', 'city', 'state', 'postal_code', 'country']
	    for field in required_address_fields:
	        if field not in command.shipping_address:
	            errors.append(f"Shipping address {field} is required")
	    
	    return errors

def _map_to_dto(self, order: Order) -> OrderDto:
    """Map domain entity to DTO"""
    return OrderDto(
        order_id=order.order_id,
        customer_id=order.customer_id,
        status=order.status.value,
        total=str(order.calculate_total()),
        items=[
            {
                'product_id': line.product_id,
                'product_name': line.product_name,
                'quantity': line.quantity,
                'unit_price': str(line.unit_price),
                'subtotal': str(line.subtotal())
            }
            for line in order.lines
        ],
        shipping_address={
            'street': order.shipping_address.street,
            'city': order.shipping_address.city,
            'state': order.shipping_address.state,
            'postal_code': order.shipping_address.postal_code,
            'country': order.shipping_address.country
        } if order.shipping_address else None,
        created_at=order.created_at.isoformat(),
        payment_status=order.payment_status.value
    )

