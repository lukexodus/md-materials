## Capacity Planning


### Sprint Capacity Calculation
```python
# Team capacity calculation example
def calculate_sprint_capacity(team_members, sprint_duration_days, availability_factor):
    """
    Calculate team capacity for sprint planning
    
    Args:
        team_members: List of (name, hours_per_day, availability_percentage)
        sprint_duration_days: Working days in sprint
        availability_factor: Factor for meetings, overhead (typically 0.8)
    
    Returns:
        Total available hours for development work
    """
    total_hours = 0
    for name, hours_per_day, availability in team_members:
        member_hours = hours_per_day * sprint_duration_days * (availability/100) * availability_factor
        total_hours += member_hours
        print(f"{name}: {member_hours:.1f} hours")
    
    return total_hours

# Example calculation for 2-week sprint
team = [
    ("Alice (Senior Dev)", 8, 90),      # 90% availability (some meetings)
    ("Bob (Mid-level)", 8, 95),        # 95% availability
    ("Charlie (Junior)", 8, 85),       # 85% availability (more learning time)
    ("David (DevOps)", 8, 80),         # 80% availability (production support)
]

capacity = calculate_sprint_capacity(team, 10, 0.8)  # 10 working days, 80% efficiency
print(f"Total Sprint Capacity: {capacity:.1f} hours")

# Convert to story points (assuming 1 story point = 4 hours)
story_points = capacity / 4
print(f"Estimated Story Point Capacity: {story_points:.0f} points")
````

### Resource Constraint Management

- **Skill Gaps**: Cross-training junior developers in testing procedures
- **Shared Resources**: Coordinate QA engineer schedule across projects
- **Peak Workloads**: Arrange temporary contractor support for testing phase
- **Knowledge Transfer**: Document critical decisions and implementation details

