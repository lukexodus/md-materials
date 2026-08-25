## Overview

class SentimentAnalyzerKS(KnowledgeSource):
    def __init__(self, name: str, blackboard: Blackboard):
        super().__init__(name, blackboard)
        self.positive_words = {'good', 'great', 'excellent', 'amazing', 'wonderful', 
                              'happy', 'love', 'best', 'perfect', 'fantastic'}
        self.negative_words = {'bad', 'terrible', 'awful', 'horrible', 'hate', 
                              'worst', 'poor', 'disappointing', 'sad', 'angry'}
    
    def can_contribute(self) -> bool:
        tokens = self.blackboard.get('tokens')
        sentiments = self.blackboard.get('sentiments')
        return tokens and not sentiments
    
    def execute(self):
        tokens = self.blackboard.get('tokens')
        
        positive_count = sum(1 for token in tokens if token in self.positive_words)
        negative_count = sum(1 for token in tokens if token in self.negative_words)
        
        if positive_count > negative_count:
            sentiment = 'positive'
            score = positive_count / (positive_count + negative_count)
        elif negative_count > positive_count:
            sentiment = 'negative'
            score = negative_count / (positive_count + negative_count)
        else:
            sentiment = 'neutral'
            score = 0.5
        
        sentiments = [{
            'sentiment': sentiment,
            'score': score,
            'positive_count': positive_count,
            'negative_count': negative_count
        }]
        
        self.blackboard.set('sentiments', sentiments, self.name)
        print(f"[{self.name}] Determined sentiment: {sentiment} (score: {score:.2f})")

