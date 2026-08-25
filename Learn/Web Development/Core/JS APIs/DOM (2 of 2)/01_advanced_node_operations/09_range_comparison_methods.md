## Range Comparison Methods


Ranges provide additional comparison capabilities through their boundary points.

### compareBoundaryPoints()

Compares boundary points of two ranges:

```javascript
range1.compareBoundaryPoints(how, sourceRange)
```

**How parameter constants:**

- `Range.START_TO_START` (0): Compare start points
- `Range.START_TO_END` (1): Compare range1 start to range2 end
- `Range.END_TO_END` (2): Compare end points
- `Range.END_TO_START` (3): Compare range1 end to range2 start

**Return values:**

- `-1`: range1 boundary comes before range2 boundary
- `0`: Boundaries are at same position
- `1`: range1 boundary comes after range2 boundary

```javascript
const range1 = document.createRange();
const range2 = document.createRange();

range1.selectNode(document.getElementById('first'));
range2.selectNode(document.getElementById('second'));

// Compare start points
const result = range1.compareBoundaryPoints(Range.START_TO_START, range2);
if (result < 0) {
    // range1 starts before range2
}
```

### intersectsNode()

[Inference] This method determines if a range intersects with a node:

```javascript
range.intersectsNode(node)
```

Returns `true` if any part of the node falls within the range boundaries.

