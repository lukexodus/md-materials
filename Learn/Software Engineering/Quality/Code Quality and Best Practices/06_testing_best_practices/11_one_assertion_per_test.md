## One assertion per test


Concept and Rationale

The principle of "One Assertion Per Test" dictates that a unit test should focus on verifying a single logical behavior, outcome, or state transition. This is a direct application of the Single Responsibility Principle (SRP) to testing code. The objective is to ensure that a test fails for exactly one reason, providing immediate clarity on what specific functionality has broken.

**Key Points**

- **Defect Localization:** If a test fails, the cause should be immediately evident. When a test contains multiple assertions checking different logical paths, a failure in an early assertion halts execution, masking whether subsequent functionalities are also broken or functional.
    
- **Test Name Clarity:** A test checking a single behavior can be named precisely (e.g., `Withdraw_ValidAmount_DecreasesBalance`). Tests with multiple assertions often result in vague names (e.g., `TestAccountOperations`), which obscure the system's specifications.
    
- **Reduced Fragility:** Tests are less coupled. Changing one aspect of the system logic (e.g., how interest is calculated) should not break a test verifying how withdrawals work, even if they operate on the same object.
    

Logical vs. Physical Assertions

It is crucial to distinguish between a single line of assertion code and a single logical assertion.

- **Physical Assertion:** A strictly literal interpretation where only one `Assert.X` method is allowed per test.
    
- **Logical Assertion:** Verifying a single coherent outcome. If a function returns a complex object, asserting that the object is correct may require checking multiple properties (fields). This is still considered "one assertion" logically because it verifies one state.
    

Example: Violation

In this scenario, three distinct behaviors are tested in one method. If the list size check fails, the developer will not know if the sorting or the retrieval logic is also broken.

**input**

C#

```
[Test]
public void TestInventoryProcessing()
{
    var inventory = new Inventory();
    inventory.Add(new Item("Apple", 5));
    inventory.Add(new Item("Banana", 10));

    // Assertion 1: Check size
    Assert.AreEqual(2, inventory.Count);

    // Assertion 2: Check total value calculation
    Assert.AreEqual(15, inventory.TotalValue());

    // Assertion 3: Check retrieval by name
    Assert.IsNotNull(inventory.Get("Apple"));
}
```

Example: Adherence

Refactoring the violation into distinct tests ensures that each behavior is validated independently.

**input**

C#

```
[Test]
public void Add_NewItems_IncrementsCount()
{
    var inventory = new Inventory();
    inventory.Add(new Item("Apple", 5));
    inventory.Add(new Item("Banana", 10));
    
    Assert.AreEqual(2, inventory.Count);
}

[Test]
public void TotalValue_ReturnsSumOfItemPrices()
{
    var inventory = new Inventory();
    inventory.Add(new Item("Apple", 5));
    inventory.Add(new Item("Banana", 10));

    Assert.AreEqual(15, inventory.TotalValue());
}

[Test]
public void Get_ExistingItemName_ReturnsItem()
{
    var inventory = new Inventory();
    inventory.Add(new Item("Apple", 5));

    Assert.IsNotNull(inventory.Get("Apple"));
}
```

Handling Complex Objects (Soft Assertions)

When a single logical action updates multiple fields, testing them individually in separate tests can be verbose and inefficient (due to repeated setup). In these cases, use "Soft Assertions" or assertion grouping features (like assertAll in JUnit 5 or FluentAssertions in .NET) to verify the entire object state at once without halting on the first failure.

**input**

Java

```
// JUnit 5 Example
@Test
void createUser_ReturnsUserWithDefaultProperties() {
    User user = userService.create("jdoe");

    // Logically one assertion: "The user was created correctly"
    // Physically multiple checks, but grouped so all are reported.
    assertAll("user",
        () -> assertEquals("jdoe", user.getUsername()),
        () -> assertTrue(user.isActive()),
        () -> assertEquals(Role.STANDARD, user.getRole())
    );
}
```

Conclusion

Adhering to "One assertion per test" creates a test suite that acts as a granular, executable specification of the system. It minimizes debugging time by ensuring that a red test points directly to the specific logic that failed, rather than requiring the developer to parse through multiple potential failure points within a single method.

Next Steps

Audit the current test suite for tests containing the word "And" in their method name or those containing blocks of comments separating different verification phases (e.g., // Verify Add, // Verify Remove). Split these into separate, atomic test methods.

---

