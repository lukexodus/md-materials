## Conflict resolution


Conflict resolution in version control refers to the process of reconciling differences when two or more developers modify the same lines of code or file structures in parallel branches. Effective conflict resolution is not merely about making the code compile again; it is about ensuring that the logical intent of both changes is preserved and integrated without introducing regressions.

**Key Points**

- **Prevention over Cure:** The most effective way to handle conflicts is to minimize them. This is achieved by keeping branches short-lived (Feature Toggles), pulling changes from the main branch frequently (Forward Integration), and decomposing the architecture so developers work on decoupled modules.
    
- **Semantic vs. Syntactic Resolution:** A common anti-pattern is resolving a conflict by simply choosing "theirs" or "ours" to make the syntax errors disappear. True resolution requires understanding _both_ changes. If Dev A renamed a function and Dev B added a call to the old function name, the code might merge without syntax markers but will fail at compile or runtime.
    
- **Tree Conflicts:** These occur when file structures change, such as when one developer edits a file that another developer has deleted or moved. These require decisions about file existence and location, not just content.
    
- **The "Rerere" Cache:** Git features "reuse recorded resolution" (rerere), which remembers how a specific conflict was resolved. If the same conflict appears again (e.g., during a rebase or a cherry-pick), Git automatically applies the previous resolution, saving time and reducing error.
    
- **Post-Resolution Verification:** A resolved merge commit is a new state of the codebase that has never existed before. It is mandatory to run the full test suite immediately after resolving conflicts to ensure the integration of the two logic streams remains stable.
    

**Example**

The Conflict Scenario

Developer A optimizes a loop. Developer B changes the loop condition.

_The Raw Conflict (Git Markers)_

JavaScript

```
function calculateTotal(items) {
<<<<<<< HEAD
    // Developer A's change (Optimized using reduce)
    return items.reduce((sum, item) => sum + item.price, 0);
=======
    // Developer B's change (Added tax logic to the loop)
    let total = 0;
    for (let i = 0; i < items.length; i++) {
        if (items[i].taxable) {
            total += items[i].price * 1.1;
        } else {
            total += items[i].price;
        }
    }
    return total;
>>>>>>> feature/tax-logic
}
```

Bad Resolution

Choosing one block entirely deletes the work of the other.

- Choosing HEAD ignores the new tax logic.
    
- Choosing feature/tax-logic ignores the functional programming refactor intended by Developer A.
    

Good Resolution (Logical Integration)

The resolver understands both intents: A wants reduce, B wants tax logic. They rewrite the code to satisfy both.

JavaScript

```
function calculateTotal(items) {
    // Combined: Using reduce (Dev A) with tax logic (Dev B)
    return items.reduce((total, item) => {
        const cost = item.taxable ? item.price * 1.1 : item.price;
        return total + cost;
    }, 0);
}
```

---

