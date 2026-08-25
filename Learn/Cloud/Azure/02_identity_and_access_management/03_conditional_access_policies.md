## Conditional Access Policies


Conditional access policies function as if-then statements that evaluate signals including user identity, location, device state, application, and risk level to make access decisions. These policies enable organizations to implement zero-trust security principles by continuously evaluating access requests based on real-time risk assessment.

Policy components include assignments (who, what, where) and access controls (grant or block access with specific requirements). Assignments define users and groups, cloud applications, and conditions such as location, device platforms, and client applications. Access controls specify whether to grant access, block access, or grant access with additional requirements like MFA or device compliance.

**Key Points:**

- Location-based access controls using named locations and IP ranges
- Device-based policies requiring compliant or domain-joined devices
- Application-specific access controls with different security requirements
- Risk-based policies leveraging Azure AD Identity Protection signals
- Session controls for monitoring and limiting user activities

Common conditional access scenarios include requiring MFA for administrative roles, blocking access from untrusted locations, requiring managed devices for sensitive applications, and implementing step-up authentication for high-risk activities.

Policy deployment follows a phased approach: report-only mode for testing impact, pilot deployment to limited user groups, and full production rollout with continuous monitoring. Microsoft recommends creating baseline security policies covering all users, administrators, and legacy authentication protocols.

