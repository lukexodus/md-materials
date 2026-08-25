## Overview

class OrderCommandHandler:
    def __init__(self, event_store: EventStore, event_publisher):
        self.event_store = event_store
        self.event_publisher = event_publisher
    
    def handle_place_order(self, command):
        """Process place order command"""
        # Create new aggregate
        order = Order(command.order_id)
        
        # Execute business logic
        order.place_order(
            command.customer_id,
            command.items,
            command.shipping_address
        )
        
        # Persist events
        self.event_store.save_events(order.id, order.uncommitted_events)
        
        # Publish events
        for event in order.uncommitted_events:
            self.event_publisher.publish('order-events', event)
    
    def handle_cancel_order(self, command):
        """Process cancel order command"""
        # Reconstitute aggregate from events
        events = self.event_store.get_events(command.order_id)
        order = Order.from_events(events)
        
        # Execute business logic
        order.cancel_order(command.reason)
        
        # Persist and publish new events
        self.event_store.save_events(order.id, order.uncommitted_events, len(events))
        
        for event in order.uncommitted_events:
            self.event_publisher.publish('order-events', event)

