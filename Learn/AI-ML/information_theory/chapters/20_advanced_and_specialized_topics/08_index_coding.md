## Index Coding

### Definition and Setup

Index coding is a source-coding problem in which a single sender broadcasts to multiple receivers over a shared noiseless channel, and each receiver already possesses **side information**: a subset of the messages the sender holds. The sender's goal is to construct a single broadcast transmission (or the shortest possible sequence of transmissions) that lets every receiver decode its individually requested message using the broadcast plus its own side information.

Formally, a sender holds a set of messages $X = \{x_1, x_2, \dots, x_n\}$. There are $n$ receivers, where receiver $i$:

- wants message $x_i$ (in the most common single-request formulation), and
- already knows a subset $S_i \subseteq X \setminus \{x_i\}$, its side-information set.

The sender must design an encoding function that maps $X$ to one or more broadcast symbols such that every receiver $i$ can recover $x_i$ from the broadcast symbols together with $S_i$. The core objective is minimizing the number of transmissions (or, in the coded case, the total broadcast length), since naive unicast to each receiver, or simple uncoded broadcast of every message, is generally wasteful given the side information available.

### Side-Information Graph

The problem structure is captured by a directed graph $G$, often called the **side-information graph** or **conflict graph**:

- Each vertex corresponds to a receiver (equivalently, to the message it wants).
- A directed edge from vertex $i$ to vertex $j$ indicates that receiver $i$ already knows message $x_j$ as side information.

This graph representation is central because it converts index coding into a graph-theoretic optimization problem: the minimum number of transmissions needed for uncoded or linear coding schemes can be characterized using graph parameters of $G$, such as the **minrank** over a given field.

$$\beta(G) = \min_{B} \operatorname{rank}(B)$$

where the minimum is taken over all matrices $B$ (over a chosen field) that "fit" $G$: $B_{ii} = 1$ for all $i$, and $B_{ij} = 0$ whenever $(i,j)$ is not an edge of $G$ (i.e., receiver $i$ does not know $x_j$). This quantity, the **minrank**, was shown by Bar-Yossef, Birk, Jayram, and Kol to characterize the optimal length of a *linear* index code over that field.

### Relation to Network Coding

Index coding is closely tied to the broader theory of network coding:

- It was shown (El Rouayheb, Sprintson, Georghiades, and separately Effros, Langberg) that **any network coding instance can be reduced to an equivalent index coding instance**, and vice versa in relevant senses — establishing index coding as a canonical, simplified proxy for studying the fundamental limits of coded broadcast and network communication.
- Because of this equivalence, hardness results and open problems in network coding (e.g., whether linear codes are always optimal, the gap between linear and nonlinear coding rates) have direct analogues in index coding, making index coding a preferred simplified setting for investigating these questions.

[Inference] The reduction results are widely cited as establishing index coding as "canonical" for network coding; the precise complexity-preserving details of the reduction constructions are technical and are best consulted directly in the original papers if exact equivalence guarantees are needed.

### Example

Consider three receivers and three messages $x_1, x_2, x_3 \in \{0,1\}$ (binary messages), with:

- Receiver 1 wants $x_1$, knows $x_2$.
- Receiver 2 wants $x_2$, knows $x_3$.
- Receiver 3 wants $x_3$, knows $x_1$.

This is a directed 3-cycle. A naive scheme would broadcast all three messages (3 transmissions). But a single coded transmission suffices:

$$y = x_1 \oplus x_2 \oplus x_3$$

- Receiver 1 computes $x_1 = y \oplus x_2 \oplus x_3$ — but it only knows $x_2$, not $x_3$, so this single-XOR-of-all-three scheme does **not** work directly for a 3-cycle with only one neighbor known each.

Correcting this: for a directed cycle where each receiver knows exactly the message of a fixed neighbor, the standard optimal scheme broadcasts the XOR of every message **that is the target of some cycle edge**, using $\lceil n/2 \rceil$-style clique-cover savings only when there is additional structure. For the pure $n$-cycle case, the well-known optimal result is that a single transmission is *not* generally achievable for all $n$; instead, the minimum number of transmissions equals $\lceil n/2 \rceil$ for an undirected cycle (Birk–Kol result on cycles), while directed cycles can sometimes do better with clique-based partitioning.

**Corrected minimal example (2-user swap):**

- Receiver 1 wants $x_1$, knows $x_2$.
- Receiver 2 wants $x_2$, knows $x_1$.

Broadcasting $y = x_1 \oplus x_2$ lets receiver 1 recover $x_1 = y \oplus x_2$, and receiver 2 recover $x_2 = y \oplus x_1$. One transmission replaces two, illustrating the basic coding gain that motivates the entire field.

### Clique Cover and Achievability Bounds

A simple achievable scheme comes from **clique cover** of the graph complement (or appropriate structure depending on convention): partition receivers/messages into groups such that within each group, every receiver already knows every other message in the group except its own desired one. XOR-ing the messages within each group into a single broadcast symbol lets every member of that group decode its target. The number of transmissions needed under this scheme equals the minimum number of cliques required to cover the graph, giving the **clique-cover bound**, an upper bound on the optimal index-coding length.

Because minrank is always at most the clique-cover number for the relevant graph representation, and coding can strictly outperform clique-cover-based uncoded/simple schemes, minrank formalizes how much benefit coding provides beyond straightforward partitioning strategies. [Inference] The exact quantitative gap between clique-cover and minrank-based schemes is instance-dependent and can be large in constructed worst-case graphs studied in the literature.

### Complexity and Fundamental Limits

- Computing the minrank of a general graph is **NP-hard**, and correspondingly, determining the optimal linear index-coding length is also NP-hard in general graphs. [Unverified] Precise hardness-of-approximation results (how well minrank can be approximated in polynomial time) are an active area with results scattered across multiple papers; specific approximation ratios should be checked against current literature rather than assumed.
- **Linear codes are not always optimal.** There exist index-coding instances where nonlinear coding strictly outperforms the best possible linear code, meaning minrank is only a tight characterization of the *linear* index-coding rate, not necessarily the true (nonlinear) capacity of the instance.
- The **interference alignment** perspective, and connections to matroid theory, have been used to construct explicit graph families demonstrating this linear/nonlinear gap.

### Variants of the Problem

- **Single unicast index coding**: each receiver wants exactly one distinct message (the standard formulation described above).
- **Multiple-request index coding**: receivers may want more than one message, generalizing the demand structure.
- **Groupcast index coding**: multiple receivers can share the same demand.
- **Fractional/vector index coding**: messages are treated as vectors over an extension field or split into sub-packets, allowing non-integer transmission-rate solutions that can outperform scalar (single-symbol) schemes.
- **Noisy/broadcast-channel index coding**: extends the noiseless broadcast assumption to channels with noise, connecting index coding to classical broadcast-channel capacity theory.

### Applications

- **Satellite and wireless broadcast systems**, where a central transmitter serves many receivers with heterogeneous cached/side content (e.g., video-on-demand caching, where users retain parts of previously viewed content).
- **Coded caching**, a closely related and highly active research area (Maddah-Ali–Niesen and successors) where index coding principles underpin the design of caching-and-delivery schemes that exploit multicast opportunities created by strategically placed cached content.
- **Distributed storage and content delivery networks**, where index-coding-style side information arises from partial replication of data across nodes.

### Diagram: 2-User Coded Swap (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 300">
<text x="320" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#222">Index Coding: 2-User Swap (svg_diagram)</text>
<circle cx="120" cy="150" r="45" fill="#e8f0fe" stroke="#3355aa" stroke-width="2" />
<text x="120" y="145" text-anchor="middle" font-size="14" fill="#222">Receiver 1</text>
<text x="120" y="165" text-anchor="middle" font-size="12" fill="#555">wants x1, knows x2</text>
<circle cx="520" cy="150" r="45" fill="#e8f0fe" stroke="#3355aa" stroke-width="2" />
<text x="520" y="145" text-anchor="middle" font-size="14" fill="#222">Receiver 2</text>
<text x="520" y="165" text-anchor="middle" font-size="12" fill="#555">wants x2, knows x1</text>
<rect x="270" y="110" width="100" height="80" rx="8" fill="#fff4e0" stroke="#cc8800" stroke-width="2" />
<text x="320" y="145" text-anchor="middle" font-size="14" fill="#222">Sender</text>
<text x="320" y="165" text-anchor="middle" font-size="13" fill="#222">y = x1 ⊕ x2</text>
<line x1="320" y1="110" x2="320" y2="60" stroke="#888" stroke-width="1.5" />
<line x1="270" y1="150" x2="165" y2="150" stroke="#3355aa" stroke-width="2" marker-end="url(#arrow)" />
<line x1="370" y1="150" x2="475" y2="150" stroke="#3355aa" stroke-width="2" marker-end="url(#arrow)" />

<text x="220" y="140" text-anchor="middle" font-size="12" fill="`#3355aa`">broadcast y</text>

<text x="420" y="140" text-anchor="middle" font-size="12" fill="`#3355aa`">broadcast y</text>

<text x="120" y="230" text-anchor="middle" font-size="12" fill="#333">decodes: x1 = y ⊕ x2</text>

<text x="520" y="230" text-anchor="middle" font-size="12" fill="#333">decodes: x2 = y ⊕ x1</text>

</svg>

### Diagram: Side-Information Graph Structure

```mermaid
graph LR
    R1["Receiver 1: wants x1"] -->|knows| R2["Receiver 2: wants x2"]
    R2 -->|knows| R3["Receiver 3: wants x3"]
    R3 -->|knows| R1
```

### Key Points

- Index coding models single-hop broadcast with receiver side information, and the side-information graph $G$ fully specifies the problem instance.
- **Minrank** over a chosen field characterizes the optimal length of linear index codes; computing it is NP-hard in general.
- Coding gains over naive/uncoded schemes arise from exploiting overlapping side information (as in the XOR-swap example).
- Linear codes are not always capacity-achieving — nonlinear coding can strictly outperform the minrank bound on some instances.
- Index coding and network coding are computationally and structurally equivalent, making index coding a canonical simplified testbed for network coding questions.
- Coded caching is a major modern application area building directly on index-coding principles.

### Related Topics

- Network coding fundamentals and the max-flow min-cut theorem for networks
- Coded caching (Maddah-Ali–Niesen scheme)
- Minrank and its connections to graph coloring and Shannon capacity of graphs
- Matroid theory and its use in constructing linear-coding-suboptimal instances
- Broadcast channel capacity (classical Shannon theory)
- Interference alignment techniques
- Distributed storage codes and content delivery network optimization