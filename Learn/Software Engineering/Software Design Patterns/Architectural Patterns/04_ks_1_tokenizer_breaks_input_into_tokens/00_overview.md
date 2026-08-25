## Overview

class TokenizerKS(KnowledgeSource):
    def can_contribute(self) -> bool:
        input_text = self.blackboard.get('input')
        tokens = self.blackboard.get('tokens')
        return input_text and not tokens
    
    def execute(self):
        input_text = self.blackboard.get('input')
        # Simple tokenization
        tokens = re.findall(r'\b\w+\b', input_text.lower())
        self.blackboard.set('tokens', tokens, self.name)
        print(f"[{self.name}] Tokenized input into {len(tokens)} tokens")

