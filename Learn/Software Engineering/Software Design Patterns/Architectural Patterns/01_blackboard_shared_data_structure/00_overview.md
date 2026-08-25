## Overview

class Blackboard:
    def __init__(self):
        self._data: Dict[str, Any] = {
            'input': '',
            'tokens': [],
            'entities': [],
            'sentiments': [],
            'themes': [],
            'confidence': 0.0,
            'status': 'initialized'
        }
        self._observers: List['BlackboardObserver'] = []
        self._history: List[Dict[str, Any]] = []
    
    def get(self, key: str) -> Any:
        """Retrieve data from blackboard"""
        return self._data.get(key)
    
    def set(self, key: str, value: Any, source: str):
        """Update blackboard data"""
        old_value = self._data.get(key)
        self._data[key] = value
        self._history.append({
            'key': key,
            'old_value': old_value,
            'new_value': value,
            'source': source
        })
        self._notify_observers(key, value, source)
    
    def get_all(self) -> Dict[str, Any]:
        """Get all blackboard data"""
        return self._data.copy()
    
    def subscribe(self, observer: 'BlackboardObserver'):
        """Add observer for blackboard changes"""
        self._observers.append(observer)
    
    def _notify_observers(self, key: str, value: Any, source: str):
        """Notify observers of changes"""
        for observer in self._observers:
            observer.on_blackboard_update(key, value, source)
    
    def display(self):
        """Display current blackboard state"""
        print("\n" + "="*60)
        print("BLACKBOARD STATE")
        print("="*60)
        for key, value in self._data.items():
            if isinstance(value, list) and len(value) > 3:
                print(f"{key}: {value[:3]}... ({len(value)} items)")
            else:
                print(f"{key}: {value}")
        print("="*60 + "\n")

