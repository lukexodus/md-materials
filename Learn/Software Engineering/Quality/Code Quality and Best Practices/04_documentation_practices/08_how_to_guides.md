## How-to guides


How-to guides are task-oriented recipes designed to solve specific problems for users who already have a basic understanding of the system. Unlike tutorials, which are for learning, how-to guides are for doing. They assume the user knows _what_ they want to achieve (e.g., "I need to add SSL to my server") but needs to know the specific steps to get there. They serve as the playbook for specific use cases.

**Key Points**

- **Problem-Focused:** The title and content should directly address a user need or a specific error scenario (e.g., "How to integrate OAuth2," "How to fix Error 503").
    
- **Context-Specific:** Unlike tutorials, how-to guides can address complex edge cases, advanced configurations, and production environments.
    
- **No Fluff:** Omit theoretical explanations of "why" something works unless it is critical for safety. The user is in "active problem-solving mode" and requires efficiency.
    
- **Prerequisites List:** Clearly state what is required before starting (e.g., "Requires Node.js v14+ and a valid API key") to prevent frustration halfway through the process.
    
- **Sanity Checks:** Include validation steps throughout the guide (e.g., "Run this command to verify the service is listening on port 80") to ensure the user hasn't deviated from the instructions.
    

**Example**

Bad (Vague/Tutorial-mix):

"Authentication is important for security. To stay safe, you should use tokens. Here is how you might start thinking about setting up a user session..."

Good (Actionable/Recipe-style):

"How to Rotate API Keys without Downtime

1. **Generate a new key:** Run `cli keys create --name=v2`.
    
2. **Add to application config:** Update your `.env` file to include `SECONDARY_API_KEY=...`.
    
3. **Redeploy:** Trigger a rolling restart of your services.
    
4. **Verify:** Check logs to ensure the new key is being accepted.
    
5. **Revoke old key:** Run `cli keys revoke --name=v1`."

---

