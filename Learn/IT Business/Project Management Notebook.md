# PERT in Project Management

PERT (Program Evaluation and Review Technique) is a project management tool used to plan, schedule, and coordinate tasks within a project. It was developed in the 1950s by the U.S. Navy for the Polaris missile program.

## Key Features

**Network Diagram Structure**
PERT uses a network diagram to visualize the sequence of tasks and their dependencies. Tasks are represented as nodes or arrows, showing which activities must be completed before others can begin.

**Time Estimation**
PERT employs three time estimates for each activity:
- Optimistic time (O): the shortest possible duration
- Most likely time (M): the most realistic duration
- Pessimistic time (P): the longest possible duration

These estimates are used to calculate the expected time using the formula: **Expected Time = (O + 4M + P) / 6**

**Critical Path**
PERT identifies the critical path—the longest sequence of dependent tasks that determines the minimum project duration. Any delay in critical path activities directly delays the entire project.

## Primary Uses

PERT is particularly useful for:
- Complex projects with many interdependent tasks
- Projects with uncertain activity durations
- Identifying which tasks have scheduling flexibility (slack time)
- Determining the probability of meeting project deadlines
- Resource allocation and risk management

## Advantages and Limitations

**Advantages:**
- Provides a visual representation of project workflow
- Helps identify potential bottlenecks early
- Accounts for uncertainty in time estimates
- Facilitates "what-if" scenario analysis

**Limitations:**
- Can be time-consuming to create and maintain for large projects
- Requires accurate time estimates, which can be difficult to obtain
- Focuses primarily on time rather than cost or resources
- May become overly complex for very large projects

PERT is often compared with CPM (Critical Path Method), and many modern project management tools incorporate elements of both techniques.

---

# Critical Path Method (CPM) Cheatsheet

## Core Terms

**Activity**: A task or work element that consumes time and resources

**Event/Node**: A point in time marking the start or end of activities

**Network Diagram**: Visual representation of project activities and their dependencies

**Critical Path**: The longest sequence of dependent activities that determines minimum project duration

**Float/Slack**: Amount of time an activity can be delayed without affecting project completion

## Key Calculations

### Forward Pass (Earliest Times)

**ES (Earliest Start)**: Earliest time an activity can begin
- First activity: ES = 0
- Subsequent activities: ES = maximum EF of all predecessors

**EF (Earliest Finish)**: Earliest time an activity can complete
- EF = ES + Duration

### Backward Pass (Latest Times)

**LF (Latest Finish)**: Latest time an activity can finish without delaying project
- Final activity: LF = EF (project completion time)
- Prior activities: LF = minimum LS of all successors

**LS (Latest Start)**: Latest time an activity can start without delaying project
- LS = LF - Duration

### Float/Slack Calculations

**Total Float (TF)**: Maximum delay without affecting project completion
- TF = LF - EF (or LS - ES)
- Critical activities: TF = 0

**Free Float (FF)**: Delay possible without affecting successor activities
- FF = (Minimum ES of successors) - EF

## Critical Path Identification

Activities are on the critical path when:
- Total Float = 0
- ES = LS and EF = LF

The critical path is the longest path through the network and determines minimum project duration.

## Activity Relationships

**Finish-to-Start (FS)**: Successor starts after predecessor finishes (most common)

**Start-to-Start (SS)**: Activities start simultaneously

**Finish-to-Finish (FF)**: Activities finish simultaneously

**Start-to-Finish (SF)**: Successor finishes when predecessor starts (rare)

## Example Calculation

For Activity B with Duration = 3 days:
- Predecessor A: EF = 5
- ES(B) = 5
- EF(B) = 5 + 3 = 8
- If LS(B) = 6, then LF(B) = 6 + 3 = 9
- Total Float = 9 - 8 = 1 day