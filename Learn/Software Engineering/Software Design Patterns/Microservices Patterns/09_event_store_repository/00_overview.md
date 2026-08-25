## Overview

class EventStore:
    def __init__(self, database):
        self.db = database
    
    def save_events(self, aggregate_id: str, events: List, expected_version: int = None):
        """Save events with optimistic concurrency check"""
        # [Inference] In a production system, this would check version conflicts
        for event in events:
            self.db.events.insert_one({
                'aggregate_id': aggregate_id,
                'event_id': event.event_id,
                'event_type': type(event).__name__,
                'event_data': vars(event),
                'timestamp': event.timestamp,
                'version': expected_version + 1 if expected_version else 1
            })
    
    def get_events(self, aggregate_id: str) -> List:
        """Retrieve all events for an aggregate"""
        event_docs = self.db.events.find(
            {'aggregate_id': aggregate_id}
        ).sort('version', 1)
        
        events = []
        for doc in event_docs:
            event_class = globals()[doc['event_type']]
            events.append(event_class(**doc['event_data']))
        
        return events

