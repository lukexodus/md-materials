## Overview


from pymongo import MongoClient
import json

class OrderReadModelUpdater:
    def __init__(self, mongo_client: MongoClient):
        self.db = mongo_client.orders_read_db
        self.processed_events = set()
    
    def handle_event(self, event):
        """Update read models based on events"""
        # Idempotency check
        if event.event_id in self.processed_events:
            return
        
        if isinstance(event, OrderPlacedEvent):
            self._handle_order_placed(event)
        elif isinstance(event, OrderCancelledEvent):
            self._handle_order_cancelled(event)
        
        self.processed_events.add(event.event_id)
        self.db.processed_events.insert_one({'event_id': event.event_id})
    
    def _handle_order_placed(self, event: OrderPlacedEvent):
        # Update order summaries collection
        self.db.order_summaries.insert_one({
            'order_id': event.order_id,
            'customer_id': event.customer_id,
            'total': event.total,
            'item_count': len(event.items),
            'status': OrderStatus.PLACED.value,
            'placed_at': event.timestamp
        })
        
        # Update customer history collection
        self.db.customer_histories.update_one(
            {'customer_id': event.customer_id},
            {
                '$push': {
                    'orders': {
                        'order_id': event.order_id,
                        'total': event.total,
                        'placed_at': event.timestamp,
                        'status': OrderStatus.PLACED.value
                    }
                },
                '$inc': {
                    'total_orders': 1,
                    'lifetime_value': event.total
                }
            },
            upsert=True
        )
    
    def _handle_order_cancelled(self, event: OrderCancelledEvent):
        # Update order summary
        self.db.order_summaries.update_one(
            {'order_id': event.order_id},
            {'$set': {'status': OrderStatus.CANCELLED.value}}
        )
        
        # Update customer history
        self.db.customer_histories.update_one(
            {'orders.order_id': event.order_id},
            {'$set': {'orders.$.status': OrderStatus.CANCELLED.value}}
        )

