## State Manipulation Commands


Several commands allow direct state file manipulation:

**terraform state list**: Shows all resources in the state file **terraform state show**: Displays detailed information about specific resources **terraform state mv**: Moves resources within state (useful for refactoring) **terraform state rm**: Removes resources from state without destroying infrastructure **terraform state pull**: Downloads and displays the current state **terraform state push**: Uploads a local state file to the backend **terraform refresh**: Updates state file with real-world resource changes **terraform force-unlock**: Manually releases stuck state locks

[Inference] These commands require careful use as they directly modify the state file, and incorrect usage could lead to infrastructure management issues.

State manipulation should typically be performed in controlled environments with proper backups and team coordination to avoid conflicts or data loss.

---

