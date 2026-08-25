## Overview

class KnowledgeSource(BlackboardObserver, ABC):
    def __init__(self, name: str, blackboard: Blackboard):
        self.name = name
        self.blackboard = blackboard
        self.blackboard.subscribe(self)
    
    @abstractmethod
    def can_contribute(self) -> bool:
        """Check if this KS can make a contribution"""
        pass
    
    @abstractmethod
    def execute(self):
        """Execute the knowledge source's contribution"""
        pass
    
    def on_blackboard_update(self, key: str, value: Any, source: str):
        """React to blackboard updates - can be overridden"""
        pass

