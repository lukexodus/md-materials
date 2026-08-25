## Core Components


### Users, Groups, and Roles

**IAM Users** represent individual people or applications that interact with AWS services. Each user has a unique name within the AWS account and can be assigned security credentials including passwords, access keys, and multi-factor authentication devices. Users can be granted permissions directly through attached policies or inherit permissions through group membership.

**IAM Groups** are collections of users that simplify permission management. Instead of attaching policies to individual users, administrators can create groups based on job functions (such as developers, administrators, or auditors) and attach policies to groups. Users inherit all permissions from their group memberships, making it easier to manage permissions at scale.

**IAM Roles** are similar to users but are intended to be assumed by anyone who needs them, rather than being uniquely associated with one person. Roles are commonly used for:

- AWS services that need to access other AWS services
- Applications running on EC2 instances
- Cross-account access scenarios
- Federated users from external identity providers

When a role is assumed, AWS provides temporary security credentials that are automatically rotated.

### Policies and Permissions

**IAM Policies** are JSON documents that define permissions using a structured format. There are several types of policies:

**Identity-based policies** attach directly to users, groups, or roles and define what actions those identities can perform on which resources.

**Resource-based policies** attach to resources (like S3 buckets) and define who can access the resource and what actions they can perform.

**AWS Managed Policies** are pre-built policies created and maintained by AWS that cover common use cases. These policies are updated by AWS when new services or features are released.

**Customer Managed Policies** are created and maintained by customers, providing precise control over permissions for specific organizational needs.

**Inline Policies** are directly embedded in a single user, group, or role and have a strict one-to-one relationship with the identity.

Policy documents use the following key elements:

- **Version**: Specifies the policy language version
- **Statement**: Contains the permission details
- **Effect**: Either "Allow" or "Deny"
- **Action**: Specifies the allowed or denied operations
- **Resource**: Defines which resources the actions apply to
- **Condition**: Optional element that specifies circumstances under which the policy grants permission

### Multi-Factor Authentication (MFA)

MFA adds an extra layer of security by requiring users to present two or more separate forms of authentication. AWS supports several MFA options:

**Virtual MFA devices** use applications like Google Authenticator, Authy, or AWS's own Virtual MFA app to generate time-based one-time passwords (TOTP).

**Hardware MFA devices** are physical tokens that generate authentication codes. AWS supports FIDO security keys and hardware TOTP tokens.

**SMS text message MFA** sends authentication codes via SMS, though this method is less secure than other options and not recommended for privileged accounts.

MFA can be required for specific actions through policy conditions, such as requiring MFA for sensitive operations like deleting resources or accessing billing information.

### Access Keys and Credentials

**Access Keys** consist of an Access Key ID and Secret Access Key pair used for programmatic access to AWS APIs. These credentials authenticate API requests and can be created for IAM users. [Inference] Best practices suggest rotating access keys regularly and avoiding embedding them in code.

**Temporary Credentials** are provided through AWS Security Token Service (STS) and include an access key ID, secret access key, and session token. These credentials have a limited lifetime and are commonly used with IAM roles.

**AWS CLI and SDK Credentials** can be configured through various methods including:

- AWS credentials file
- Environment variables
- IAM roles for EC2 instances
- AWS SSO
- Cross-account roles

### Cross-Account Access

Cross-account access enables resources in one AWS account to access resources in another AWS account securely. This is typically implemented through:

**Cross-account roles** where the trusted account assumes a role in the trusting account. The trusting account creates a role with the necessary permissions and specifies which external accounts can assume it.

**Resource-based policies** can grant access to users or roles from other accounts directly on resources that support them, such as S3 buckets, KMS keys, and Lambda functions.

**External ID** is an optional condition that can be used in cross-account scenarios to prevent the "confused deputy" problem, where an entity with privileges is tricked into performing actions on behalf of a less privileged entity.

### Identity Federation

Identity federation allows users to access AWS resources using credentials from external identity providers rather than creating separate IAM users. AWS supports several federation methods:

**SAML 2.0 Federation** enables integration with corporate identity providers like Active Directory Federation Services (ADFS), allowing users to access AWS using their corporate credentials.

**Web Identity Federation** allows users to sign in using web identity providers like Amazon, Facebook, Google, or any OpenID Connect (OIDC) compatible provider.

**AWS Single Sign-On (SSO)** provides a centralized way to manage access to multiple AWS accounts and business applications. It can connect to external identity sources or maintain its own identity store.

**AWS Cognito** is designed for mobile and web applications, providing user pools for authentication and identity pools for authorization.

### AWS Organizations

AWS Organizations is a service for centrally managing multiple AWS accounts. It provides:

**Organizational Units (OUs)** which are containers for accounts that help organize accounts hierarchically.

**Service Control Policies (SCPs)** which are type of organization policy that can be used to manage permissions in organization accounts. SCPs offer central control over the maximum available permissions for all accounts in an organization, but they don't grant permissions themselves.

**Account management** features including programmatic account creation, consolidated billing, and centralized logging configuration.

**Cross-account sharing** capabilities for resources like VPCs, subnets, and Transit Gateways through AWS Resource Access Manager (RAM).

