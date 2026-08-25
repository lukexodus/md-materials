## Specification Pattern


The specification pattern encapsulates business rules as composable predicates that can be combined using logical operators. This enables complex validation and filtering logic to be built from simple, reusable components.

**Basic Specification**

A specification is a predicate function that returns boolean:

```javascript
const spec = (predicate) => ({
  isSatisfiedBy: predicate,
  and: (other) => spec((x) => predicate(x) && other.isSatisfiedBy(x)),
  or: (other) => spec((x) => predicate(x) || other.isSatisfiedBy(x)),
  not: () => spec((x) => !predicate(x))
});

const isAdult = spec((person) => person.age >= 18);
const hasLicense = spec((person) => person.license === true);

const canDrive = isAdult.and(hasLicense);
canDrive.isSatisfiedBy({ age: 20, license: true }); // true
```

**Function Composition Approach**

Specifications as pure functions with combinators:

```javascript
const and = (...specs) => (x) => specs.every(spec => spec(x));
const or = (...specs) => (x) => specs.some(spec => spec(x));
const not = (spec) => (x) => !spec(x);

const isAdult = (person) => person.age >= 18;
const hasLicense = (person) => person.license === true;
const hasInsurance = (person) => person.insurance === true;

const canDrive = and(isAdult, hasLicense);
const canDriveLegally = and(canDrive, hasInsurance);
```

**Parameterized Specifications**

Create specification factories that capture parameters:

```javascript
const hasMinAge = (minAge) => (person) => person.age >= minAge;
const hasMaxAge = (maxAge) => (person) => person.age <= maxAge;
const ageInRange = (min, max) => and(hasMinAge(min), hasMaxAge(max));

const isTeenager = ageInRange(13, 19);
const isSenior = hasMinAge(65);
```

**Filtering with Specifications**

Apply specifications to collections for filtering:

```javascript
const activeUser = (user) => user.status === 'active';
const premiumUser = (user) => user.tier === 'premium';
const recentlyActive = (days) => (user) => 
  (Date.now() - user.lastLogin) < days * 86400000;

const targetUsers = and(
  activeUser,
  premiumUser,
  recentlyActive(30)
);

const filtered = users.filter(targetUsers);
```

**Query Specification Pattern**

Translate specifications into query objects for databases:

```javascript
const toQuery = (spec) => spec.toQuery();

const ageSpec = (min, max) => ({
  isSatisfiedBy: (person) => person.age >= min && person.age <= max,
  toQuery: () => ({ age: { $gte: min, $lte: max } })
});

const statusSpec = (status) => ({
  isSatisfiedBy: (person) => person.status === status,
  toQuery: () => ({ status })
});

const activeAdults = and(ageSpec(18, 100), statusSpec('active'));
// Can be used in-memory or converted to DB query
```

**Validation Specifications**

Build complex validation rules:

```javascript
const required = (field) => (obj) => obj[field] !== undefined && obj[field] !== null;
const minLength = (field, len) => (obj) => obj[field]?.length >= len;
const matches = (field, regex) => (obj) => regex.test(obj[field]);

const validEmail = and(
  required('email'),
  minLength('email', 5),
  matches('email', /^[^\s@]+@[^\s@]+\.[^\s@]+$/)
);

const validPassword = and(
  required('password'),
  minLength('password', 8),
  matches('password', /[A-Z]/),
  matches('password', /[0-9]/)
);

const validUser = and(validEmail, validPassword);
```

**Specification with Context**

Pass additional context to specifications:

```javascript
const canAccessResource = (user, resource) => 
  user.role === 'admin' || resource.ownerId === user.id;

const canEditResource = (user, resource) =>
  canAccessResource(user, resource) && resource.locked === false;

const withContext = (spec, context) => (obj) => spec(obj, context);

const userCanEdit = withContext(canEditResource, currentUser);
resources.filter(userCanEdit);
```

**Lazy Evaluation**

Delay specification execution until needed:

```javascript
const lazy = (specFn) => {
  let cached = null;
  return {
    isSatisfiedBy: (x) => {
      if (cached === null) cached = specFn();
      return cached(x);
    }
  };
};

const expensiveSpec = lazy(() => {
  const data = loadLargeDataset();
  return (x) => data.includes(x.id);
});
```

**Key Points**

- Specifications are composable predicates that encode business rules
- Logical operators (and, or, not) combine simple specs into complex ones
- Parameterized specs capture configuration through closures
- Can be applied to in-memory filtering or translated to database queries
- Enables declarative business logic that's easy to test and reuse
- Separation of rule definition from rule application improves maintainability

---

