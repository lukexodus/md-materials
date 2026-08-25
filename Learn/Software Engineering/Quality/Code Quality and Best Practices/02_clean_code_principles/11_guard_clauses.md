## Guard clauses


A guard clause is a specific application of the early return pattern focused on preconditions. It asserts that specific criteria are met before the main logic of the function executes. If the criteria are not met, the function exits immediately, often with an error or exception.

**Key Points**

- **Defensive Programming:** Guard clauses enforce the contract of the function, ensuring that invalid data does not propagate deep into the system logic where debugging becomes harder.
    
- **Fail Fast:** They immediately halt execution upon encountering an invalid state, preventing partial execution or side effects that might occur before a later error is caught.
    
- **Separation of Concerns:** Checks for validation are separated from the actual business logic. The top of the function handles "can I do this?", and the rest handles "doing this."
    
- **Exception Handling:** Guard clauses are the standard location for throwing exceptions regarding invalid arguments (e.g., `ArgumentNullException`, `IllegalArgumentException`).
    

**Example**

_Bad Practice_

C#

```
public void UpdateCustomerAddress(Customer customer, Address newAddress)
{
    // Main logic mixed with validation
    if (customer != null)
    {
        if (newAddress != null)
        {
            if (newAddress.IsValid())
            {
                customer.Address = newAddress;
                _repository.Save(customer);
            }
            else
            {
                throw new ArgumentException("Invalid address");
            }
        }
        else
        {
            throw new ArgumentNullException(nameof(newAddress));
        }
    }
    else
    {
        throw new ArgumentNullException(nameof(customer));
    }
}
```

_Good Practice_

C#

```
public void UpdateCustomerAddress(Customer customer, Address newAddress)
{
    // Guard Clauses
    if (customer == null) 
        throw new ArgumentNullException(nameof(customer));
        
    if (newAddress == null) 
        throw new ArgumentNullException(nameof(newAddress));
        
    if (!newAddress.IsValid()) 
        throw new ArgumentException("Invalid address", nameof(newAddress));

    // Main Execution
    customer.Address = newAddress;
    _repository.Save(customer);
}
```

---

