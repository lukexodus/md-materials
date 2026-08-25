## Overview

class EntityRecognizerKS(KnowledgeSource):
    def __init__(self, name: str, blackboard: Blackboard):
        super().__init__(name, blackboard)
        self.entity_patterns = {
            'email': r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
            'url': r'https?://[^\s]+',
            'phone': r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b',
            'money': r'\$\d+(?:,\d{3})*(?:\.\d{2})?'
        }
    
    def can_contribute(self) -> bool:
        tokens = self.blackboard.get('tokens')
        entities = self.blackboard.get('entities')
        return tokens and not entities
    
    def execute(self):
        input_text = self.blackboard.get('input')
        entities = []
        
        for entity_type, pattern in self.entity_patterns.items():
            matches = re.finditer(pattern, input_text)
            for match in matches:
                entities.append({
                    'type': entity_type,
                    'value': match.group(),
                    'position': match.span()
                })
        
        self.blackboard.set('entities', entities, self.name)
        print(f"[{self.name}] Found {len(entities)} entities")

