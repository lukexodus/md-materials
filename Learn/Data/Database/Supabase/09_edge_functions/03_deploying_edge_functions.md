## Deploying Edge Functions


Deployment pushes your local function code to Supabase's edge infrastructure, making it available at a unique URL endpoint. Functions deploy individually or in batches, with versioning and rollback capabilities.

**Deployment commands:**

Deploy a specific function: `supabase functions deploy function-name`

Deploy all functions: `supabase functions deploy`

Each deployment creates a new version while maintaining the same public URL. The platform handles zero-downtime deployments by gradually routing traffic to the new version.

**Deployment workflow:**

Link your local project to a Supabase project using `supabase link --project-ref your-project-ref`. This establishes the connection between your local environment and the remote project where functions will deploy.

After linking, the deploy command bundles your TypeScript code, resolves dependencies, and uploads everything to the edge infrastructure. The CLI provides real-time feedback on the deployment status.

**Verification and testing:**

After deployment, test the function using its generated URL: `https://your-project-ref.supabase.co/functions/v1/function-name`

Functions appear in the Supabase Dashboard under Edge Functions, where you can view logs, invocation metrics, and configuration settings.

**Example deployment output:**

```
Deploying function hello-world...
Bundle size: 12.3 KB
Function URL: https://abcdefgh.supabase.co/functions/v1/hello-world
Deployed successfully in 3.2s
```

**Version management:**

Each deployment is immutable. To update a function, deploy again with modified code. The previous version remains in history but becomes inactive. [Inference] Rollback capabilities may be available through the dashboard or CLI, though specific rollback commands are not confirmed in this context.

