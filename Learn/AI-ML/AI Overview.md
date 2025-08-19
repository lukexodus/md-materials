# AI Terminology and Key Concepts

## **What is AI?**
- **Artificial Intelligence**: Concerned with the design of intelligence in an artificial device (McCarthy, 1956) 
- **Core Question**: What constitutes intelligence - human-level behavior or absolute optimal performance? 
- **Behavioral Focus**: Whether we examine thought processes/reasoning or final actions/manifestations

## **Four Main Approaches to AI**

### **1. Human-Centered AI**
- Systems designed to be as intelligent as humans 
- Involves understanding human thought processes 
- Attempts to build machines that emulate human reasoning

### **2. Turing Test Approach**
- Machine must fool an interrogator into believing it's human 
- Focus on convincing human-like responses 
- Behavioral indistinguishability from humans

### **3. Logic and Laws of Thought**
- Studies ideal or rational thought processes 
- Emphasis on logical inference and reasoning 
- Mathematical and formal approaches to thinking

### **4. Rational Agent Approach**
- Building machines that act rationally 
- Focus on optimal performance and actions 
- Less concerned with reasoning process, more with results

## **AI Problem Categories**

### **Common-place Tasks**
- Recognizing people and objects 
- Natural language communication 
- Navigation around obstacles

### **Expert Tasks**
- Medical diagnosis 
- Mathematical problem solving 
- Game playing (chess, etc.)

## **AI Classification Systems**

### **Strong AI**
- Aims to build truly reasoning machines 
- Self-aware systems 
- Intellectual ability indistinguishable from humans

### **Weak AI**
- Creates computer-based artificial intelligence 
- Cannot truly reason but acts intelligently 
- Simulates intelligence without genuine understanding

### **Applied AI**
- Produces commercially viable "smart" systems 
- Examples: security systems, practical applications 
- Has achieved considerable commercial success

### **Cognitive AI**
- Uses computers to test theories about human mind 
- Studies face recognition, object identification 
- Explores abstract problem-solving mechanisms

## **Current AI Capabilities and Limitations**

### **Computer Vision**
- Face recognition systems 
- Object identification capabilities

### **Robotics**
- Mostly autonomous vehicles 
- Navigation and movement systems

### **Natural Language Processing**
- Simple machine translation 
- Text categorization systems

### **Expert Systems**
- Medical diagnosis in narrow domains 
- Specialized knowledge applications

### **Speech Recognition**
- Recognition of thousands of words 
- Continuous speech processing

### **Game Playing**
- Grand Master level chess performance 
- World champion level in checkers 
- Strategic game analysis

### **Planning and Scheduling**
- Automated planning systems 
- Resource allocation and timing

## **Relationship to Other Disciplines**
- **Computer Science**: Computational foundations and algorithms 
- **Psychology**: Understanding human cognition and behavior 
- **Philosophy**: Questions about mind, consciousness, and reasoning 
- **Mathematics**: Logic, statistics, and optimization methods 
- **Neuroscience**: Brain structure and neural processing 
- **Linguistics**: Language structure and communication

## **Practical Impact**
- **Embedded Systems**: AI integrated into everyday devices 
- **Consumer Applications**: Widespread use in daily life 
- **Industrial Systems**: Automation and smart manufacturing

---

# What is an Agent?

## **Basic Definition**
- **Agent**: A system that acts in an environment 
- **Core Function**: Implements a mapping from percept sequences to actions 
- **Autonomy**: Decides independently which actions to take to maximize progress toward goals

## **Agent Components**

### **Input System**
- **Sensors**: Perceive the environment 
- **Percept**: Complete set of inputs at a given time 
- **Percept Sequence**: History of all percepts received

### **Output System**
- **Actuators/Effectors**: Change the environment 
- **Action**: Operation involving an effector

## **Agent Performance Evaluation**

### **Performance Measures**
- **Speed/Efficiency**: How quickly tasks are completed 
- **Accuracy/Quality**: How well solutions meet requirements 
- **Resource Usage**: Power consumption, cost, etc. 
- **Subjective Measure**: Characterizes agent success level

### **Ideal vs. Actual Performance**
- **Ideal Mapping**: Specifies optimal actions at any point 
- **Agent Function**: Actual behavior implementation 
- **Performance Gap**: Difference between ideal and actual behavior

## **Examples of Agents**

### **Human Agents**
- **Sensors**: Eyes, ears, skin, taste buds 
- **Actuators**: Hands, fingers, legs, mouth

### **Robot Agents**
- **Sensors**: Camera, sonar, infrared, bumpers 
- **Actuators**: Grippers, wheels, lights, speakers, motors

### **Software Agents**
- **Softbots**: Software with sensor and actuator functions 
- **Expert Systems**: Knowledge-based decision makers 
- **Autonomous Spacecraft**: Space exploration systems 
- **Intelligent Buildings**: Environmental control systems

## **Agent Faculties**
- **Acting**: Ability to perform actions in environment 
- **Sensing**: Ability to perceive environmental changes 
- **Understanding/Reasoning/Learning**: Cognitive capabilities for decision-making

## **Intelligent Agent Requirements**
- **Must Sense**: Perceive environmental information 
- **Must Act**: Perform actions to affect environment 
- **Must be Autonomous**: Make independent decisions 
- **Must be Rational**: Always attempt optimal actions

## **Rationality Concepts**

### **Perfect Rationality** [Theoretical]
- Agent knows everything about environment 
- Takes action that maximizes utility 
- [Unverified] - Real agents cannot achieve perfect rationality due to computational and information limitations

### **Bounded Rationality** [Practical]
- Agent acts optimally within resource constraints 
- Limited by computational power and available information 
- More realistic model for real-world agents

### **Rational Action**
- Action that maximizes expected performance measure value 
- Based on percept sequence available to date 
- Not omniscient - doesn't know actual outcomes

## **Agent Environment Characteristics**

### **Observability**
- **Fully Observable**: All relevant environment features visible 
- **Partially Observable**: Only some relevant features visible

### **Determinism**
- **Deterministic**: Next state completely determined by current state and action 
- **Stochastic**: Next state involves randomness or uncertainty

### **Episodicity**
- **Episodic**: Episodes independent of previous episodes 
- **Sequential**: Connected series of episodes affect each other

### **Continuity**
- **Discrete**: Limited number of distinct percepts and actions 
- **Continuous**: Unlimited range of percepts and actions

### **Agent Presence**
- **Single Agent**: Only one agent in environment 
- **Multi-Agent**: Multiple agents interact in environment

## **Agent Architectures**

### **1. Table-Based Agents**
- **Function**: Look up actions from predefined table 
- **Implementation**: Direct percept-to-action mapping 
- **Example**: Traffic light control systems 
- **Limitations**: Exponential table size growth with percept complexity

### **2. Reflex Agents (Percept-Based)**
- **Function**: React directly to current percepts using condition-action rules 
- **Characteristics**:
- Efficient operation 
- No internal representation for reasoning 
- No strategic planning or learning 
- Poor for multiple/opposing goals 
- **Example**: Vacuum cleaning robots

### **3. Brooks' Subsumption Architecture**
- **Features**:
- No explicit knowledge representation
- Distributed, not centralized behavior
- Reflexive response to stimuli
- Bottom-up design approach
- Simple individual agents with emergent complex behavior

### **4. Model-Based Reflex Agents (State-Based)**
- **Function**: Maintain internal state representation of world 
- **Process**: Percepts → State Update → Action Selection 
- **Example**: Self-driving cars with world models 
- **Advantage**: Can handle partially observable environments

### **5. Goal-Based Agents**
- **Function**: Select actions to achieve specific goals 
- **Process**: Percepts → State → Goal Consideration → Action Planning 
- **Example**: Autonomous delivery robots 
- **Capabilities**: Strategic planning and goal-directed behavior

### **6. Utility-Based Agents**
- **Function**: Maximize expected utility across multiple objectives 
- **Process**: Evaluate actions based on utility function 
- **Example**: Autonomous vehicles balancing safety, speed, efficiency, comfort 
- **Advantage**: Handle conflicting objectives optimally

### **7. Learning Agents**
- **Function**: Improve performance through experience 
- **Components**: Learning element modifies performance element 
- **Requirement**: Essential for true autonomy in unknown environments 
- **Example**: Virtual personal assistants that adapt to user preferences 
- **Capabilities**: Continuous improvement and adaptation

## **Agent Design Questions**
1. **Functionalities**: What are the agent's goals and capabilities? 
2. **Components**: What sensors, actuators, and processing elements are needed? 
3. **Implementation**: How do we build and deploy the agent system?

---

# Basic Notion of State Space Search

## **Fundamental Concepts**

### **What is Search in AI?**
- **Definition**: Mental exploration of possibilities before taking actual action 
- **Importance**: Most important and general AI programming technique 
- **Purpose**: General-purpose problem-solving approach for intelligent agents

### **Core Philosophy**
- **Before Acting**: Intelligent agents explore possibilities mentally 
- **Mental Simulation**: Consider various scenarios without physical execution 
- **Decision Making**: Choose optimal path based on exploration results

## **Key Components of State Space Search**

### **States and Actions**
- **Initial State**: Starting configuration description of the agent 
- **State**: Specific configuration or situation in the problem space 
- **Action/Operator**: Transforms agent from one state to another 
- **Successor State**: Resulting state after applying an action

### **Plans and Costs**
- **Plan**: Sequence of actions leading from initial to goal state 
- **Path Cost**: Total cost of executing a plan 
- **Cost Calculation**: [Inference] Often sum of individual step costs

## **Search Problem Formal Definition**

### **Mathematical Components**
- **S**: Full set of all possible states 
- **s₀**: Initial state (starting point) 
- **A: S → S**: Set of operators/actions that transform states 
- **G**: Set of goal/final states (where G ⊆ S)

### **Problem Formulation Process**
- **State Selection**: Choose relevant set of states to consider 
- **Operator Selection**: Define feasible set of actions for state transitions 
- **Goal Definition**: Specify conditions for successful problem solution

## **Search Process Methodology**

### **General Search Algorithm**

1. **Check Current State**: Evaluate present configuration 
2. **Generate Successors**: Execute allowable actions to find new states 
3. **State Selection**: Pick one of the newly generated states 
4. **Goal Testing**: Check if new state satisfies goal conditions 
5. **Iteration**: If not goal state, make new state current and repeat

### **Termination Conditions**
- **Solution Found**: Goal state reached successfully 
- **State Space Exhausted**: All possible states explored without solution

## **Representation Methods**

### **Graph Representation**
- **Directed Graph**: Visual representation of search problem 
- **Nodes**: Represent individual states in the problem space 
- **Arcs/Edges**: Represent allowed actions between states 
- **Direction**: Shows permitted state transitions

## **Examples of Search Problems**

### **15-Puzzle Problem**
- **Initial State**: Scrambled tile configuration 
- **Goal State**: Specific arrangement (e.g., top row: tiles 1, 2, 3) 
- **Actions**: Sliding tiles into empty space 
- **State Space**: All possible tile arrangements

### **Maze Navigation**
- **Initial State**: Starting position in maze 
- **Goal State**: HOME position 
- **Actions**: Move up, down, left, right 
- **Constraints**: Cannot move through walls

### **Pegs and Disks Problem (Tower of Hanoi)**
- **Setup**: 3 pegs and 3 disks of different sizes 
- **Initial State**: All disks on one peg (e.g., peg A) 
- **Goal State**: All disks moved to target peg (e.g., peg B) 
- **Actions**: Move topmost disk from any peg to any other peg 
- **Constraints**:
- Can only move one disk at a time
- Can only move topmost disk
- Cannot place larger disk on smaller disk

## **Search Strategy Considerations**

### **Exploration vs. Exploitation**
- **Breadth**: Explore many possibilities at shallow depth 
- **Depth**: Explore fewer possibilities at greater depth 
- **Balance**: [Inference] Optimal strategy depends on problem characteristics

### **Efficiency Factors**
- **State Space Size**: Total number of possible states 
- **Branching Factor**: Average number of actions per state 
- **Solution Depth**: Number of steps in optimal solution 
- **Path Cost**: Resource requirements for solution execution

## **Problem-Solving Benefits**
- **Risk Reduction**: Explore consequences before committing to actions 
- **Optimization**: Find best solution among alternatives 
- **Planning**: Structured approach to complex problem-solving 
- **Systematicity**: Comprehensive exploration of solution space

---

# State Space Search Algorithms

## **Basic Search Framework**

### **Required Components**
- **Set of States**: All possible problem configurations 
- **Operators and Costs**: Actions that transform states with associated costs 
- **Start State**: Initial problem configuration 
- **Goal Test**: Method to check if current state satisfies goal conditions

### **Generic Search Algorithm**

```
Let L be a list containing the initial state (L = the fringe)
Loop:
    if L is empty return failure
    Node ← select(L)
    if Node is a goal then return Node
        (the path from initial state to Node)
    else
        generate all successors of Node, and 
        merge the newly generated states into L
End Loop
```

## **Search Algorithm Key Issues**

### **Structural Considerations**
- **Unbounded Search Tree**: [Potential Issue] Tree may grow infinitely without proper termination 
- **Return Format**: Decision between returning complete path or final node 
- **Graph Weighting**: Search graph may have weighted or unweighted edges

### **Algorithm Selection Factors**
- **Problem Characteristics**: Size, complexity, and structure of state space 
- **Resource Constraints**: Available time and memory limitations 
- **Solution Requirements**: Quality vs. speed trade-offs

## **Search Strategy Evaluation Criteria**

### **Completeness**
- **Definition**: Strategy guaranteed to find solution if one exists 
- **Importance**: Ensures algorithm won't fail on solvable problems 
- **Failure Cases**: [Inference] Incomplete strategies may miss existing solutions

### **Optimality**
- **Definition**: Solution has minimal cost among all possible solutions 
- **Cost Types**: Path length, resource usage, or problem-specific metrics 
- **Trade-offs**: [Inference] Optimal solutions may require more computational resources

### **Search Cost Analysis**

#### **Time Complexity**
- **Measurement**: Number of nodes expanded to find solution 
- **Cases**: Worst-case or average-case performance analysis 
- **Growth**: [Inference] Often exponential with problem size

#### **Space Complexity**
- **Measurement**: Maximum size of fringe during search 
- **Memory Usage**: Storage requirements for search process 
- **Limiting Factor**: [Inference] Often more constraining than time in practice

## **Search Tree Terminology**

### **Node Types**
- **Root Node**: Starting point of search process 
- **Leaf Node**: Node with no children in search tree 
- **Internal Node**: Node with one or more children

### **Relationships**
- **Ancestor/Descendant**:
- X is ancestor of Y if X is Y's parent or ancestor of Y's parent
- If X is ancestor of Y, then Y is descendant of X 
- **Parent/Child**: Direct connection between nodes in tree

### **Tree Characteristics**
- **Branching Factor (b)**: Maximum number of children for any non-leaf node 
- **Path Types**:
- **Complete Path**: Starts with root node, ends with goal node
- **Partial Path**: Any other path in search tree

## **Node Data Structure**

### **Essential Components**
- **State Description**: Current problem configuration 
- **Parent Pointer**: Reference to generating node 
- **Depth**: Distance from root node 
- **Generating Operator**: Action that created this node 
- **Path Cost**: Sum of operator costs from start state

### **Usage Benefits**
- **Path Reconstruction**: Trace back to find complete solution path 
- **Cost Tracking**: Monitor resource usage during search 
- **Duplicate Detection**: [Inference] Identify previously visited states

## **State Space Graph vs. Search Tree**
- **State Space Graph**: All possible states and transitions 
- **Search Tree**: Specific exploration path through state space 
- **Relationship**: [Inference] Search tree is subset of state space graph 
- **Cycles**: Graph may contain cycles, tree representation avoids them

## **Uninformed Search Strategies**

### **Strategy Types**
- **Breadth-First Search**: Explore all nodes at current depth before deeper nodes 
- **Depth-First Search**: Explore as deeply as possible before backtracking 
- **Depth-Limited Search**: Depth-first with maximum depth constraint 
- **Iterative Deepening**: Repeated depth-limited search with increasing limits 
- **Uniform Cost Search**: Explore lowest-cost nodes first

## **Breadth-First Search (BFS)**

### **Algorithm Description**
- **Approach**: Begin at root, explore all neighboring nodes first 
- **Expansion Order**: Level-by-level exploration of search tree 
- **Fringe Management**: Use queue (FIFO) data structure

### **BFS Algorithm**

``` 
Let fringe be a list containing the initial state
Loop:
    if fringe is empty return failure
    Node ← remove-first(fringe)
    if Node is a goal then return path from initial state to Node
    else 
        generate all successors of Node, and
        add generated nodes to the back of fringe
End Loop
```

## **Properties of Breadth-First Search**

### **Completeness and Optimality**
- **Complete**: Always finds solution if one exists 
- **Optimal Conditions**:
- Optimal if all operators have same cost
- Otherwise finds solution with shortest path length
- [Inference] May not find lowest-cost solution with varying operator costs

### **Complexity Analysis**
- **Time Complexity**: O(b^d) where b = branching factor, d = depth 
- **Space Complexity**: O(b^d) - same as time complexity 
- **Node Count Formula**: 1 + b + b² + ... + b^(d-1) = (b^d - 1)/(b-1)

### **Exponential Growth**
- **Problem**: [Unverified] Exponential complexity can make BFS impractical for large problems 
- **Memory Requirements**: Must store entire frontier simultaneously 
- **Scaling Issues**: [Inference] Performance degrades rapidly with increasing depth or branching factor

## **Advantages of Breadth-First Search**
- **Minimal Path Length**: Finds shortest path to goal (in terms of steps) 
- **Systematic Exploration**: Guarantees finding shallowest solution first 
- **Completeness**: [Inference] Will not get stuck in infinite branches like depth-first approaches

## **Disadvantages of Breadth-First Search**
- **Exponential Storage**: Requires generation and storage of exponentially-sized tree 
- **Memory Intensive**: [Inference] May exhaust available memory before finding solution 
- **Time Intensive**: [Inference] Must explore many irrelevant nodes before finding goal 
- **Impractical for Deep Solutions**: [Inference] Becomes infeasible when shallowest goal is at significant depth

---

## Depth-First Search and Advanced Search Strategies

### **Depth-First Search (DFS)**

#### **Core Concept**
- **Algorithm Purpose**: Traversing or searching tree, tree structure, or graph 
- **Strategy**: Start at root, explore as far as possible along each branch before backtracking 
- **Search Direction**: Searches deeper into problem space before exploring alternatives

#### **DFS Implementation Details**
- **Data Structure**: Uses Last-In-First-Out (LIFO) stack for unexpanded nodes 
- **Node Selection**: Always selects most recently added node for exploration 
- **Expansion**: Goes to maximum depth before considering siblings

#### **DFS Algorithm**

```
Let fringe be a list containing the initial state
Loop:
    if fringe is empty return failure
    Node ← remove-first(fringe)
    if Node is a goal then
        return the path from initial state to Node
    else 
        generate all successors of Node, and
        add generated nodes to the front of fringe
End Loop
```

### **Advantages of Depth-First Search**

#### **Memory Efficiency**
- **Linear Memory**: Memory requirement only linear with respect to search graph 
- **Space Complexity**: O(bd) where b = branching factor, d = maximum depth 
- **Storage Benefits**: [Inference] Significantly more memory-efficient than BFS for deep searches

#### **Performance Benefits**
- **Time Complexity**: O(b^d) - generates same set of nodes as breadth-first search 
- **Fast Solutions**: [Inference] If solution exists on explored path, finds it quickly without extensive exploration 
- **Resource Efficiency**: [Inference] Uses minimal space and time when solution is found early

### **Disadvantages of Depth-First Search**

#### **Completeness Issues**
- **Infinite Paths**: [Potential Problem] May go down left-most path forever 
- **No Solution Guarantee**: Not guaranteed to find solution even if one exists 
- **Infinite Loops**: [Inference] Can get trapped in cycles without proper cycle detection

#### **Optimality Problems**
- **Non-Optimal**: No guarantee to find minimal solution when multiple solutions exist 
- **Path Quality**: [Inference] May find longer, more expensive paths before shorter ones 
- **Cost Insensitivity**: [Inference] Doesn't consider path costs in node selection

#### **Systematic Limitations**
- **Incomplete Search**: [Inference] May never explore certain branches of search tree 
- **Order Dependency**: [Inference] Solution quality depends heavily on node ordering 
- **Backtracking Overhead**: [Inference] May waste time exploring unpromising deep paths

### **Depth-First Iterative Deepening (DFID) Search**

#### **Hybrid Approach**
- **Combination Strategy**: Combines best features of breadth-first and depth-first search 
- **Progressive Deepening**: Performs series of depth-limited searches with increasing limits 
- **Complete Coverage**: Ensures systematic exploration of entire search space

#### **DFID Process**
1. **Depth 1**: Perform complete depth-first search to depth one 
2. **Depth 2**: Start over, execute complete depth-first search to depth two 
3. **Continue**: Run depth-first searches to successively greater depths 
4. **Termination**: Continue until solution is found

#### **DFID Advantages**
- **Memory Efficiency**: Maintains linear space complexity of DFS 
- **Completeness**: Guarantees finding solution if one exists 
- **Optimal Path Length**: Finds shortest path like BFS (when operators have equal cost)

### **Properties of DFID Search**

#### **Completeness and Optimality**
- **Complete**: Always finds solution if one exists 
- **Optimal Conditions**:
- Optimal/Admissible if all operators have same cost
- Otherwise guarantees shortest length solution (like BFS)
- [Inference] Not cost-optimal with varying operator costs

#### **Complexity Analysis**
- **Node Generation Formula**: b^d + 2b^(d-1) + 3b^(d-2) + ... + db 
- **Upper Bound**: ≤ b^d / (1 - 1/b)² = O(b^d) 
- **Time Complexity**: O(b^d) - same asymptotic complexity as BFS 
- **Space Complexity**: O(bd) - linear space like DFS

#### **Efficiency Characteristics**
- **Redundant Work**: [Inference] Repeats shallow searches multiple times 
- **Overhead**: [Inference] Extra computation compensated by memory savings 
- **Practical Performance**: [Inference] Often better than BFS for problems with limited memory

### **Uniform Cost Search (UCS)**

#### **Algorithm Purpose**
- **Weighted Graphs**: Tree search algorithm for traversing weighted structures 
- **Cost-Optimal**: Finds lowest-cost path to goal state 
- **Systematic Exploration**: Explores nodes in order of increasing path cost

#### **UCS Strategy**
- **Starting Point**: Search begins at root node 
- **Node Selection**: Visit next node with least total cost from root 
- **Priority Ordering**: Uses priority queue ordered by cumulative path cost

#### **UCS Characteristics**
- **Optimality**: [Inference] Guarantees finding lowest-cost solution 
- **Completeness**: [Inference] Complete if step costs are positive 
- **Applications**: [Inference] Ideal for problems where actions have different costs

#### **UCS vs. Other Strategies**
- **vs. BFS**: Considers path costs, not just path length 
- **vs. DFS**: Systematic cost-based exploration rather than depth-first 
- **vs. DFID**: Cost-optimal rather than length-optimal

### **Search Strategy Comparison**

#### **Memory Usage**
- **BFS**: O(b^d) - exponential space 
- **DFS**: O(bd) - linear space  
- **DFID**: O(bd) - linear space 
- **UCS**: [Inference] Depends on cost distribution, typically between BFS and DFS

#### **Solution Quality**
- **BFS**: Shortest path (equal costs) 
- **DFS**: No optimality guarantee 
- **DFID**: Shortest path (equal costs) 
- **UCS**: Lowest-cost path (varying costs)

#### **Completeness**
- **BFS**: Complete 
- **DFS**: Incomplete (infinite spaces) 
- **DFID**: Complete 
- **UCS**: Complete (positive step costs)

---

# Knowledge Representation

## Representation Overview
- AI agents handle three types of knowledge: facts (believe & observe), procedures (how-to), and meaning (relate & define) 
- Choosing the right representation is crucial - wrong choice can lead to project failure 
- Some techniques require specific representations (e.g., first-order theorem proving needs first-order logic)

## General Representation Types
- **Logical Representations** - formal languages with concrete rules and no ambiguity 
- **Production Rules** - "if condition then action" pairs with match-resolve-act cycles 
- **Semantic Networks** - graphical representations including conceptual graphs and frames 
- **Description Logics** - specialized logical systems

## Propositional Logic
- Uses propositions connected by logical operators (and, or, not, implies, equivalent) 
- Semantics defined through truth tables showing how connectives affect truth values 
- Key concepts include validity (true for any interpretation), satisfiability (true for at least one interpretation), and unsatisfiability (false for all interpretations)

## First-Order Logic (Predicate Logic)
- More expressive than propositional logic 
- Uses constants (objects), predicates (properties/relations), functions (object transformers), and variables 
- Includes quantifiers: universal (∀ - for all) and existential (∃ - there exists) 
- Can represent complex relationships like "Every gardener likes the sun" or "There exists some bird that doesn't fly"

## Non-Logical Representations
- **Production Rules** use working memory and conflict resolution when multiple rules can fire 
- **Semantic Networks** provide graphical representation with nodes and labeled links 
- **Conceptual Graphs** represent single propositions with concept nodes and relation nodes 
- **Frames** are structured nodes with slots for specific information, supporting inheritance and default values

## Key Insight
- All "non-logical" representations can actually be expressed in first-order logic 
- This provides both logical precision and application-specific intuitive representations 
- Specialized representations can make reasoning easier and more efficient for specific domains

---

# NLP

## What is NLP?
- AI method of communicating with intelligent systems using natural language (like English)
- Combines linguistics and computer science to decipher language structure and create models that can comprehend, analyze, and extract significant details from text and speech

## Components of NLP
- **Natural Language Understanding (NLU)**  
- Maps natural language input into useful representations  
- Analyzes different aspects of language
- **Natural Language Generation (NLG)**  
- Produces meaningful phrases and sentences from internal representations  
- Involves text planning, sentence planning, and text realization

## Difficulties in NLU
- Natural language has extremely rich form and structure
- High levels of ambiguity including:  
- Lexical ambiguity  
- Syntax level ambiguity  
- Referential ambiguity
- One input can have different meanings
- Many inputs can mean the same thing

## Key Terminologies
- **Phonology** - systematic study of organizing sound
- **Morphology** - study of word construction from meaningful units
- **Morpheme** - primitive unit of meaning in language
- **Syntax** - arranging words to make sentences and determining structural roles
- **Semantics** - concerned with word meaning and combining words meaningfully
- **Pragmatics** - using and understanding sentences in different situations
- **Discourse** - how preceding sentences affect interpretation of following sentences
- **World Knowledge** - general knowledge about the world

## Steps in NLP Processing
- **Lexical Analysis** - identifying and analyzing word structure, dividing text into paragraphs, sentences, and words
- **Syntactic Analysis (Parsing)** - analyzing words for grammar and showing relationships between words
- **Semantic Analysis** - extracting exact meaning by mapping syntactic structures to task domain objects
- **Discourse Integration** - considering meaning based on preceding and succeeding sentences
- **Pragmatic Analysis** - deriving aspects requiring real-world knowledge

## Data Preprocessing Steps
- Segmentation
- Tokenizing
- Removing stop words
- Stemming
- Lemmatization
- Part of Speech Tagging
- Named Entity Tagging - classifying words into subcategories (person, location, monetary value, quantity, organization, movie, etc.)

## Applications of NLP
- Translation tools
- Chatbots
- Virtual assistants
- Targeted advertising
- Autocorrect

## Context Free Grammars
- Used to describe context-free languages through recursive rules
- Generate patterns of strings and can describe all regular languages and more
- Applied in theoretical computer science, compiler design, and linguistics

## CFG Components
- **Terminal symbols** - characters appearing in generated strings (never on left-hand side of production rules)
- **Nonterminal symbols** - placeholders for terminal symbol patterns (always appear on left-hand side of production rules)
- **Production rules** - rules for replacing nonterminal symbols (format: variable → string of variables and terminals)
- **Start symbol** - special nonterminal symbol in initial generated string

## CFG String Creation Process
- Begin with start symbol
- Apply production rules by replacing left-hand side with right-hand side
- Repeat until all nonterminals are replaced by terminal symbols