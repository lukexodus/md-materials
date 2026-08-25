## Overview

def analyze_text(text: str):
    # Create blackboard
    blackboard = Blackboard()
    blackboard.set('input', text, 'system')
    
    # Create controller
    controller = BlackboardController(blackboard)
    
    # Register knowledge sources
    controller.add_knowledge_source(TokenizerKS('Tokenizer', blackboard))
    controller.add_knowledge_source(EntityRecognizerKS('EntityRecognizer', blackboard))
    controller.add_knowledge_source(SentimentAnalyzerKS('SentimentAnalyzer', blackboard))
    controller.add_knowledge_source(ThemeIdentifierKS('ThemeIdentifier', blackboard))
    controller.add_knowledge_source(ConfidenceEvaluatorKS('ConfidenceEvaluator', blackboard))
    
    # Run the system
    controller.run()
    
    return blackboard

