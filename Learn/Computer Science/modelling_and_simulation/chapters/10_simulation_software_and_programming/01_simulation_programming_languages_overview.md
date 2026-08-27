## Simulation Programming Languages

### Overview

Simulation programming languages and frameworks are software tools purpose-built (or specifically extended) to support the construction, execution, and analysis of simulation models — including discrete-event, agent-based, system dynamics, and continuous simulation paradigms. Unlike general-purpose programming languages, these tools typically provide built-in constructs for time management, random number generation, scheduling, statistical output collection, and visualization, substantially reducing the boilerplate required to build a valid simulation from scratch.

### Categories of Simulation Software

**General-Purpose Languages with Simulation Libraries**
Standard programming languages (Python, Java, C++) augmented with simulation-specific libraries, offering maximum flexibility at the cost of more manual implementation effort.

**Domain-Specific Simulation Languages**
Languages purpose-designed for simulation, often with declarative or specialized syntax for agents, events, or system-dynamics stocks/flows (e.g., GAML in GAMA, Simula's class-based event scheduling).

**Visual/Graphical Modeling Environments**
Tools using drag-and-drop or block-diagram interfaces requiring minimal or no traditional coding (e.g., AnyLogic's flowchart-style process modeling, Vensim/Stella for system dynamics).

**Hybrid Multi-Paradigm Platforms**
Tools supporting agent-based, discrete-event, and system-dynamics modeling within a single environment, allowing different paradigms to be combined in one model.

```mermaid
flowchart TD
    A[Simulation Modeling Need (svg_diagram)] --> B{Paradigm Required}
    B -->|Agent-Based| C[NetLogo / Mesa / Repast / GAMA]
    B -->|Discrete-Event| D[SimPy / AnyLogic / Arena]
    B -->|System Dynamics| E[Vensim / Stella / AnyLogic]
    B -->|Multi-Paradigm| F[AnyLogic / Repast Simphony]
    C --> G[Select Based on Skill Level, Scale, Licensing]
    D --> G
    E --> G
    F --> G
```

### Agent-Based Modeling Languages and Platforms

**NetLogo**
A widely used educational and research ABM platform with an accessible, Logo-derived scripting language centered on "turtles" (mobile agents), "patches" (grid cells), and "links" (network edges).

```plaintext
to setup
  clear-all
  create-turtles 100 [ setxy random-xcor random-ycor ]
  reset-ticks
end

to go
  ask turtles [ move-and-interact ]
  tick
end
```

Strengths: gentle learning curve, strong pedagogical use, large model library (NetLogo Models Library). Limitations: less suited to very large-scale or high-performance production simulations.

**Mesa (Python)**
An object-oriented ABM framework in Python, defining agents as classes with a `step()` method, and using a `Model` class to manage scheduling, data collection, and visualization.

```python
class MyAgent(Agent):
    def step(self):
        self.move()
        self.interact()

class MyModel(Model):
    def __init__(self, n):
        self.schedule = RandomActivation(self)
        for i in range(n):
            a = MyAgent(i, self)
            self.schedule.add(a)

    def step(self):
        self.schedule.step()
```

Strengths: native Python ecosystem integration (NumPy, pandas, scikit-learn), highly flexible for custom analysis pipelines. Limitations: generally requires more manual implementation than NetLogo for basic models.

**Repast (Repast Simphony / Repast4Py)**
A Java-based (Repast Simphony) and Python-based (Repast4Py, designed for high-performance computing/MPI parallelization) family of ABM platforms, supporting large-scale, GIS-integrated, and network-based models.

**MASON**
A fast, discrete-event-scheduled, Java-based ABM library emphasizing computational efficiency for large-scale simulations, with separate 2D/3D visualization layers decoupled from the model logic.

**GAMA / GAML**
A platform using the GAML declarative language, with strong built-in support for GIS data integration, making it popular for spatially explicit ecological, urban, and geographic simulations.

```plaintext
species people {
    reflex move {
        location <- location + {1,0};
    }
}
```

**AnyLogic**
A commercial, Java-based multi-method platform combining agent-based, discrete-event, and system-dynamics modeling in a single graphical/hybrid-coding environment, widely used in industry (logistics, healthcare, manufacturing).

### Discrete-Event Simulation Languages and Libraries

**SimPy (Python)**
A process-based discrete-event simulation library using Python generators to represent processes that yield control while waiting for events (e.g., resource availability, timers).

```python
def car(env):
    while True:
        print(f'Start parking at {env.now}')
        yield env.timeout(5)
        print(f'Start driving at {env.now}')
        yield env.timeout(2)
```

**Arena**
A long-standing commercial discrete-event simulation tool widely used in industrial engineering and operations research, using a flowchart-based modeling interface built on the underlying SIMAN simulation language.

**Simula**
Historically significant as the first object-oriented programming language, originally designed explicitly for discrete-event simulation; introduced foundational concepts (classes, objects, coroutines) that later shaped Java, C++, and most modern OOP languages.

**GPSS (General Purpose Simulation System)**
One of the earliest discrete-event simulation languages (1960s), using a block-diagram transaction-flow paradigm; direct ancestor of many later process-based DES tools.

### System Dynamics Software

**Vensim**
A widely used system dynamics modeling tool for building stock-and-flow diagrams and simulating continuous-time differential-equation-based models, common in policy, environmental, and business modeling.

**Stella / iThink**
Graphical system-dynamics environments emphasizing accessible stock-flow diagramming for education and business applications.

$$
\frac{dS}{dt} = \text{Inflow}(t) - \text{Outflow}(t)
$$

where $S$ is a stock (accumulation) and inflow/outflow are rate-based flow variables — the core building block of system dynamics models, distinct from the individual-entity focus of ABM/DES.

### Selecting a Simulation Language/Platform

| Consideration | Guidance |
|---|---|
| Paradigm needed | Agent-based → NetLogo/Mesa/GAMA; discrete-event → SimPy/Arena; system dynamics → Vensim/Stella; mixed → AnyLogic/Repast |
| Team programming skill | Non-programmers/education → NetLogo, Stella; programmers wanting flexibility → Mesa, SimPy |
| Scale/performance needs | Large-scale/HPC → Repast4Py, MASON, custom C++; small/medium → NetLogo, Mesa |
| Spatial/GIS integration | Strong GIS needs → GAMA, Repast Simphony, AnyLogic |
| Licensing/budget | Open-source → NetLogo, Mesa, SimPy, Repast; commercial/enterprise support → AnyLogic, Arena, Vensim |
| Visualization needs | Built-in interactive visualization → NetLogo, AnyLogic; custom/programmatic → Mesa + external plotting libraries |

[Unverified: specific feature sets, licensing terms, and performance benchmarks for each named platform change over time and across versions; consult current official documentation before making a platform selection for a production project.]

### General-Purpose Languages Used for Custom Simulation Development

Beyond dedicated platforms, simulations are frequently built directly in general-purpose languages when maximum control, integration with existing codebases, or specific performance requirements are needed:

- **Python**: rapid prototyping, extensive scientific computing ecosystem (NumPy, SciPy, pandas), but slower raw execution speed for very large-scale simulations without optimization (e.g., NumPy vectorization, Cython, or JIT compilation via Numba)
- **Java**: strong OOP support, mature ecosystem, underlies several major ABM platforms (Repast, MASON) directly or via JVM interoperability
- **C/C++**: maximum performance for large-scale or high-performance computing simulations, at the cost of longer development time and more manual memory/resource management
- **Julia**: increasingly used for scientific/simulation computing, combining Python-like syntax accessibility with performance closer to compiled languages

### Interoperability and Extensions

Many platforms support extensions or interfacing with external tools to combine strengths:

- NetLogo's Python and R extensions for statistical analysis pipelines
- Mesa's integration with the broader Python data science stack
- GIS data import/export (shapefiles, raster data) across GAMA, Repast, and AnyLogic
- Export to common data formats (CSV, HDF5) for downstream analysis regardless of originating platform

### Key Points

- Simulation software spans a spectrum from general-purpose languages with simulation libraries to fully domain-specific, declarative simulation languages
- Platform choice should be driven by required paradigm (ABM, DES, system dynamics, or hybrid), team programming background, performance/scale needs, and spatial data requirements
- NetLogo, Mesa, Repast, MASON, and GAMA represent the dominant options specifically for agent-based modeling, each with distinct trade-offs in accessibility versus performance versus GIS integration
- SimPy, Arena, and the historically foundational Simula/GPSS represent the discrete-event simulation lineage
- Vensim and Stella represent the system-dynamics lineage, modeling continuous stocks and flows rather than discrete individual entities
- Interoperability (extensions, data export/import) allows combining the strengths of specialized platforms with general-purpose analysis ecosystems

**Related Topics**
- Discrete-Event Simulation Fundamentals and Event Scheduling
- System Dynamics: Stocks, Flows, and Feedback Loops
- Performance Optimization in Large-Scale Agent-Based Simulation
- GIS Integration in Spatially Explicit Simulation Models
- Multi-Paradigm and Hybrid Simulation Modeling
- Parallel and Distributed Simulation (HPC Approaches)
- Random Number Generation and Variance Reduction Techniques
- Simulation Output Analysis and Statistical Validation