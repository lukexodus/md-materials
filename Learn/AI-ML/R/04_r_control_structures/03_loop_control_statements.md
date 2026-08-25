## Loop Control Statements


### break Statement

Immediately exits the innermost loop:

```r
for (i in 1:10) {
    if (i == 5) break
    print(i)
}
# Prints 1, 2, 3, 4 then exits
```

### next Statement

Skips current iteration and continues with next:

```r
for (i in 1:5) {
    if (i == 3) next
    print(i)
}
# Prints 1, 2, 4, 5 (skips 3)
```

