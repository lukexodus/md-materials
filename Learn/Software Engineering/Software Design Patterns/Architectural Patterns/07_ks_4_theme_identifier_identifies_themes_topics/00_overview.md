## Overview

class ThemeIdentifierKS(KnowledgeSource):
    def __init__(self, name: str, blackboard: Blackboard):
        super().__init__(name, blackboard)
        self.theme_keywords = {
            'technology': {'computer', 'software', 'internet', 'digital', 'tech', 'app', 'website'},
            'business': {'company', 'market', 'sales', 'profit', 'business', 'customer', 'product'},
            'health': {'health', 'medical', 'doctor', 'patient', 'hospital', 'treatment', 'care'},
            'education': {'school', 'student', 'teacher', 'learning', 'education', 'study', 'class'}
        }
    
    def can_contribute(self) -> bool:
        tokens = self.blackboard.get('tokens')
        themes = self.blackboard.get('themes')
        return tokens and not themes
    
    def execute(self):
        tokens = self.blackboard.get('tokens')
        token_set = set(tokens)
        
        themes = []
        for theme, keywords in self.theme_keywords.items():
            matches = token_set.intersection(keywords)
            if matches:
                themes.append({
                    'theme': theme,
                    'confidence': len(matches) / len(keywords),
                    'matched_keywords': list(matches)
                })
        
        # Sort by confidence
        themes.sort(key=lambda x: x['confidence'], reverse=True)
        
        self.blackboard.set('themes', themes, self.name)
        print(f"[{self.name}] Identified {len(themes)} themes")

