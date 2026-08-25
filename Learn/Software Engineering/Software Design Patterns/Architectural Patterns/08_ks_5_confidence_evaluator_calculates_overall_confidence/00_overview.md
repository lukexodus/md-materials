## Overview

class ConfidenceEvaluatorKS(KnowledgeSource):
    def can_contribute(self) -> bool:
        entities = self.blackboard.get('entities')
        sentiments = self.blackboard.get('sentiments')
        themes = self.blackboard.get('themes')
        confidence = self.blackboard.get('confidence')
        return entities is not None and sentiments and themes and confidence == 0.0
    
    def execute(self):
        entities = self.blackboard.get('entities')
        sentiments = self.blackboard.get('sentiments')
        themes = self.blackboard.get('themes')
        tokens = self.blackboard.get('tokens')
        
        # Calculate confidence based on various factors
        entity_score = min(len(entities) / 5, 1.0) * 0.3  # Up to 30%
        sentiment_score = sentiments[0]['score'] * 0.3  # Up to 30%
        theme_score = (themes[0]['confidence'] if themes else 0) * 0.4  # Up to 40%
        
        overall_confidence = entity_score + sentiment_score + theme_score
        
        self.blackboard.set('confidence', overall_confidence, self.name)
        self.blackboard.set('status', 'completed', self.name)
        print(f"[{self.name}] Overall confidence: {overall_confidence:.2f}")

