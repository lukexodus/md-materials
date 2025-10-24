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