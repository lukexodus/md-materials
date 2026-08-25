## Multi-Factor Authentication


Multi-factor authentication (MFA) in Azure AD requires users to provide additional verification factors beyond username and password, significantly reducing the risk of account compromise. Azure MFA supports various authentication methods including phone calls, SMS messages, mobile app notifications, and hardware tokens.

The service integrates seamlessly with Azure AD and can be applied selectively through conditional access policies or globally across all user accounts. Azure MFA provides detailed reporting and monitoring capabilities, allowing administrators to track authentication patterns and identify potential security threats.

**Example:** A user logging into Azure portal first enters their credentials, then receives a push notification on their Microsoft Authenticator app requiring approval before access is granted.

Organizations can customize MFA settings including trusted IP ranges, app passwords for legacy applications, and fraud alert configurations. The service supports both cloud-based and on-premises MFA server deployments, though Microsoft recommends the cloud-based approach for new implementations.

Authentication methods vary in security strength and user convenience. Microsoft Authenticator app provides the highest security through certificate-based authentication, while SMS and phone calls offer broader compatibility but lower security due to potential SIM swapping and phone interception attacks.

