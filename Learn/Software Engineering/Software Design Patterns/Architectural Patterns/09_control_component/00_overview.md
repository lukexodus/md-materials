## Overview

class BlackboardController:
    def __init__(self, blackboard: Blackboard):
        self.blackboard = blackboard
        self.knowledge_sources: List[KnowledgeSource] = []
        self.max_iterations = 20
    
    def add_knowledge_source(self, ks: KnowledgeSource):
        """Register a knowledge source"""
        self.knowledge_sources.append(ks)
    
    def run(self):
        """Execute the blackboard system"""
        print("Starting Blackboard System...")
        self.blackboard.display()
        
        iteration = 0
        while iteration < self.max_iterations:
            iteration += 1
            print(f"\n--- Iteration {iteration} ---")
            
            # Find knowledge sources that can contribute
            applicable_ks = [ks for ks in self.knowledge_sources if ks.can_contribute()]
            
            if not applicable_ks:
                print("No more applicable knowledge sources. Stopping.")
                break
            
            # Execute the first applicable knowledge source
            # In more complex systems, prioritization logic would go here
            selected_ks = applicable_ks[0]
            print(f"Executing: {selected_ks.name}")
            selected_ks.execute()
            
            # Check if we're done
            if self.blackboard.get('status') == 'completed':
                print("\nProblem solving completed!")
                break
        
        self.blackboard.display()

