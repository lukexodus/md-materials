## Overview

class BlackboardObserver(ABC):
    @abstractmethod
    def on_blackboard_update(self, key: str, value: Any, source: str):
        pass

