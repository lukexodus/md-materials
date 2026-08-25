## Testing error conditions


Testing error conditions (often called "Negative Testing" or "Unhappy Path Testing") ensures that an application handles invalid inputs, unexpected states, and infrastructure failures gracefully without crashing, corrupting data, or exposing security vulnerabilities. While happy path testing confirms the software does what it is supposed to do, error condition testing confirms it does not do what it is forbidden to do.

**Categories of Error Conditions**

- **Input Validation Failures:** Providing arguments that violate domain rules (e.g., null values, empty strings, negative numbers where positives are expected, buffer overflows).
    
- **State Violations:** Invoking operations that are invalid for the current state of the object or system (e.g., popping from an empty stack, approving an already closed order).
    
- **Environmental & Resource Failures:** Simulating external system failures such as network timeouts, database connection drops, disk full errors, or memory exhaustion.
    
- **Dependency Contracts:** Handling unexpected responses from third-party APIs, including malformed JSON, 5xx server errors, or unexpected 2xx responses.
    

**Strategies for Validating Errors**

- **Precise Exception Assertions:** It is insufficient to verify that _an_ exception was thrown. Tests must assert the **exact type** of the exception and inspect the **exception message** or error code to ensure the failure reason is correct. This prevents "false positives" where the test passes because of a `NullPointerException` (bug) instead of the expected `IllegalArgumentException` (validation).
    
- **Atomicity and State Rollback:** A critical aspect of error testing is verifying the system state _after_ the error. If a transaction fails halfway through, the test must ensure no partial data was committed and that resources (connections, file handles) were released.
    
- **Fault Injection:** For hard-to-reproduce errors (like checking how a system behaves when a disk write fails), use fault injection tools or mocks to force dependencies to throw specific errors.
    
- **Boundary Value Analysis:** Errors often occur at the edges. Test conditions specifically at, just below, and just above the limits (e.g., max integer size, max string length).
    

**Example**

The following example demonstrates testing a `MoneyTransferService`. It validates both the exception type/message and the system state after the failure to ensure atomicity.

Java

```
// SUT: Service being tested
public void transfer(AccountId from, AccountId to, BigDecimal amount) {
    if (amount.compareTo(BigDecimal.ZERO) <= 0) {
        throw new IllegalArgumentException("Transfer amount must be positive");
    }
    // ... complex transfer logic
}

// TEST CODE
@Test
void shouldRejectNonPositiveTransferAmount() {
    // Arrange
    BigDecimal invalidAmount = new BigDecimal("-100");
    
    // Act & Assert
    IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
        transferService.transfer(senderId, receiverId, invalidAmount);
    });

    // Verify Exception Details
    assertEquals("Transfer amount must be positive", exception.getMessage());
}

@Test
void shouldNotDeductBalanceWhenTransactionFails() {
    // Arrange
    Mockito.doThrow(new DatabaseConnectionException())
           .when(accountRepository).update(any());
           
    // Act
    assertThrows(DatabaseConnectionException.class, () -> {
        transferService.transfer(senderId, receiverId, new BigDecimal("100"));
    });

    // Assert Side Effects (Atomicity)
    // Verify that despite the crash, the sender's balance remains untouched
    verify(accountRepository, never()).save(any());
    assertEquals(new BigDecimal("1000"), accountRepository.getBalance(senderId));
}
```

**Common Anti-Patterns**

- **The "Catch-All" Test:** Using `@Test(expected = Exception.class)` or catching `Exception`. This masks regressions because it will catch `NullPointerException` or `IndexOutOfBoundsException` just as readily as the business logic error you intended to test.
    
- **Swallowing Exceptions:** A test block that catches an exception and prints the stack trace without failing the test (e.g., empty catch block).
    
- **Ignoring Side Effects:** Verifying the error was reported but failing to verify that the database was not corrupted by the failed operation.
    

**Key Points**

- **Resilience:** Error testing drives the design of robust error handling mechanisms and prevents "fragile" code.
    
- **Security:** Many security vulnerabilities (DoS, info leakage) are exposed via unhandled error conditions.
    
- **Documentation:** These tests document exactly how the API communicates failure to the client.

---

