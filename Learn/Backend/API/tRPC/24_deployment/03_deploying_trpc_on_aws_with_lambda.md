## Deploying tRPC on AWS Lambda

AWS Lambda runs tRPC procedures as invocation-scoped functions. The execution model is similar to Vercel's serverless functions but with more configuration surface: runtime selection, memory allocation, VPC placement, concurrency controls, and IAM permissions are all explicit. The primary integration path is through API Gateway (HTTP API or REST API), which translates HTTP requests into Lambda invocations.

---

### Execution Model

Each Lambda invocation:

1. May reuse a warm execution environment (container) from a prior invocation
2. May cold-start a fresh environment — downloading the deployment package, initializing the runtime, running module-level code
3. Executes the handler function
4. Freezes the environment until the next invocation or timeout

Code outside the handler runs once per cold start and is reused across warm invocations. This makes it the correct place for database client initialization, SDK setup, and router construction — identical to the `globalThis` pattern used in Next.js on Vercel.

> [Inference] Warm environment reuse is a Lambda implementation detail and is not contractually guaranteed. Global state should be treated as potentially reused, but never as reliably persistent. Behavior under concurrent invocations (multiple warm instances) means global state is per-instance, not shared.

---

### API Gateway Variants

Two API Gateway products front Lambda for HTTP workloads:

| | HTTP API (v2) | REST API (v1) |
|---|---|---|
| Latency | Lower | Higher |
| Cost | Lower | Higher |
| Features | Basic routing, JWT auth, CORS | Full request/response transformation, API keys, usage plans |
| Payload limit | 10 MB | 10 MB |
| WebSockets | Separate WebSocket API product | Separate WebSocket API product |

For tRPC, HTTP API is the standard choice unless REST API features (usage plans, API keys, fine-grained request transformation) are required.

---

### Adapter Options

tRPC does not ship a first-party Lambda adapter. Two community options are widely used:

**`@h3` / Nitro** — framework-level; wraps tRPC in a Nitro server deployable to Lambda.

**`@trpc/server/adapters/aws-lambda`** — the official Lambda adapter added in tRPC v11. Handles API Gateway v1 (REST), v2 (HTTP), and ALB (Application Load Balancer) event formats.

This section uses the official adapter.

---

### Installation

```bash
npm install @trpc/server @trpc/client zod
npm install --save-dev aws-cdk-lib constructs esbuild
```

For bundling:

```bash
npm install --save-dev esbuild
```

---

### tRPC Router

The router itself is platform-agnostic. No Lambda-specific code belongs here.

```ts
// src/trpc/router.ts
import { initTRPC } from '@trpc/server';
import { z } from 'zod';
import { Context } from './context';

const t = initTRPC.context<Context>().create();

export const appRouter = t.router({
  user: t.router({
    getById: t.procedure
      .input(z.object({ id: z.string() }))
      .query(async ({ input, ctx }) => {
        return ctx.db.user.findUniqueOrThrow({ where: { id: input.id } });
      }),
    create: t.procedure
      .input(z.object({ name: z.string(), email: z.string().email() }))
      .mutation(async ({ input, ctx }) => {
        return ctx.db.user.create({ data: input });
      }),
  }),
});

export type AppRouter = typeof appRouter;
```

---

### Context with Lambda Event

The Lambda adapter passes the raw API Gateway event and Lambda context into `createContext`:

```ts
// src/trpc/context.ts
import { CreateAWSLambdaContextOptions } from '@trpc/server/adapters/aws-lambda';
import { APIGatewayProxyEventV2 } from 'aws-lambda';
import { db } from '../lib/db';

export function createContext({
  event,
  context,
}: CreateAWSLambdaContextOptions<APIGatewayProxyEventV2>) {
  // Extract auth token from Authorization header
  const token = event.headers?.authorization?.replace('Bearer ', '');

  return {
    db,
    token,
    requestId: context.awsRequestId,
    event, // available if procedures need raw event access
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

---

### Lambda Handler

```ts
// src/handler.ts
import { awsLambdaRequestHandler } from '@trpc/server/adapters/aws-lambda';
import { APIGatewayProxyEventV2, APIGatewayProxyStructuredResultV2, Context } from 'aws-lambda';
import { appRouter } from './trpc/router';
import { createContext } from './trpc/context';

// Initialized outside handler — reused across warm invocations
// Database client initialization happens in lib/db.ts at module load time

export const handler = awsLambdaRequestHandler({
  router: appRouter,
  createContext,
  responseMeta({ errors, type }) {
    // Add cache headers to successful queries
    if (type === 'query' && errors.length === 0) {
      return {
        headers: {
          'Cache-Control': 'max-age=60, stale-while-revalidate=300',
        },
      };
    }
    return {};
  },
});
```

The `handler` export name must match the handler configuration in Lambda (`handler.handler` in this case — file `handler.js`, export `handler`).

---

### Database Connections in Lambda

Lambda functions do not maintain persistent TCP connections between invocations. The same constraints as Vercel apply, with the same solutions:

**RDS Proxy** — AWS-native connection pooler for RDS (PostgreSQL, MySQL). Sits between Lambda and RDS, maintaining a pool of database connections:

```ts
// lib/db.ts — Prisma pointing to RDS Proxy endpoint
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const db = globalForPrisma.prisma ?? new PrismaClient({
  // RDS Proxy endpoint — same connection string format as direct RDS
  // but routes through the proxy's pool
  datasources: { db: { url: process.env.DATABASE_URL } },
});

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = db;
}
```

RDS Proxy requires IAM authentication or a Secrets Manager secret. It is a paid AWS service.

**HTTP-based drivers** (Neon, PlanetScale) — same approach as Vercel; avoids connection management entirely.

---

### Bundling with esbuild

Lambda requires a self-contained deployment package. `esbuild` produces a single-file bundle fast:

```ts
// scripts/build.ts
import { build } from 'esbuild';

await build({
  entryPoints: ['src/handler.ts'],
  bundle: true,
  platform: 'node',
  target: 'node20',
  outfile: 'dist/handler.js',
  external: [
    // Exclude packages with native binaries — must be in a Lambda layer
    '@prisma/client',
    'prisma',
  ],
  minify: true,
  sourcemap: true,
});
```

Add to `package.json`:

```json
{
  "scripts": {
    "build": "ts-node scripts/build.ts",
    "deploy": "npm run build && cdk deploy"
  }
}
```

> [Inference] Prisma Client generates platform-specific query engine binaries. These must target `linux-arm64` (for ARM Lambda) or `rhel-openssl-3.0.x` (for x86_64 Lambda), not the host machine's platform. Set `binaryTargets` in `schema.prisma` accordingly and include the generated client in the bundle or a Lambda layer. Behavior depends on Prisma version and Lambda runtime.

```prisma
// schema.prisma
generator client {
  provider      = "prisma-client-js"
  binaryTargets = ["native", "rhel-openssl-3.0.x", "linux-arm64"]
}
```

---

### Infrastructure with AWS CDK

CDK defines Lambda functions, API Gateway, and supporting resources as TypeScript code:

```ts
// infrastructure/stack.ts
import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigw from 'aws-cdk-lib/aws-apigatewayv2';
import * as apigwIntegrations from 'aws-cdk-lib/aws-apigatewayv2-integrations';
import * as sm from 'aws-cdk-lib/aws-secretsmanager';
import { Construct } from 'constructs';

export class TRPCStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const dbSecret = sm.Secret.fromSecretNameV2(
      this, 'DBSecret', 'trpc/database-url'
    );

    const trpcFunction = new lambda.Function(this, 'TRPCHandler', {
      runtime: lambda.Runtime.NODEJS_20_X,
      architecture: lambda.Architecture.ARM_64, // cheaper and often faster than x86_64
      handler: 'handler.handler',
      code: lambda.Code.fromAsset('dist', {
        // Exclude source maps from production bundle to reduce package size
        exclude: ['*.map'],
      }),
      memorySize: 512,          // MB — increase for CPU-bound procedures
      timeout: cdk.Duration.seconds(30),
      environment: {
        NODE_ENV: 'production',
        DATABASE_URL: dbSecret.secretValue.unsafeUnwrap(), // use secretsmanager integration in practice
      },
      // Place in VPC if database is in a private subnet
      // vpc,
      // vpcSubnets: { subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS },
    });

    const httpApi = new apigw.HttpApi(this, 'TRPCApi', {
      apiName: 'trpc-api',
      corsPreflight: {
        allowHeaders: [
          'Content-Type',
          'Authorization',
          'traceparent',
          'tracestate',
          'baggage',
        ],
        allowMethods: [apigw.CorsHttpMethod.GET, apigw.CorsHttpMethod.POST],
        allowOrigins: ['https://app.example.com'],
        maxAge: cdk.Duration.days(1),
      },
    });

    const lambdaIntegration = new apigwIntegrations.HttpLambdaIntegration(
      'TRPCIntegration',
      trpcFunction
    );

    httpApi.addRoutes({
      path: '/trpc/{proxy+}',
      methods: [apigw.HttpMethod.GET, apigw.HttpMethod.POST],
      integration: lambdaIntegration,
    });

    new cdk.CfnOutput(this, 'ApiUrl', {
      value: httpApi.apiEndpoint,
    });
  }
}
```

```ts
// infrastructure/app.ts
import * as cdk from 'aws-cdk-lib';
import { TRPCStack } from './stack';

const app = new cdk.App();

new TRPCStack(app, 'TRPCStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION ?? 'us-east-1',
  },
});
```

Deploy:

```bash
npx cdk bootstrap   # first time only — sets up CDK assets bucket
npx cdk deploy
```

---

### Secrets Management

Hardcoding secrets in Lambda environment variables exposes them in the AWS console. Prefer Secrets Manager or Parameter Store:

```ts
// Retrieve secret at cold start, cache for warm invocations
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: process.env.AWS_REGION });
let cachedSecret: string | undefined;

async function getDatabaseUrl(): Promise<string> {
  if (cachedSecret) return cachedSecret;

  const response = await client.send(new GetSecretValueCommand({
    SecretId: 'trpc/database-url',
  }));

  cachedSecret = response.SecretString!;
  return cachedSecret;
}

// In createContext or db.ts initialization:
const databaseUrl = await getDatabaseUrl();
```

> [Inference] Caching the secret in a module-scoped variable means it persists across warm invocations. If the secret is rotated, the cached value becomes stale until the next cold start. AWS recommends using the Secrets Manager Lambda extension to handle rotation transparently, but its configuration is outside tRPC's scope. Behavior depends on rotation policy.

Grant the Lambda function IAM permission to read the secret:

```ts
// In CDK stack
dbSecret.grantRead(trpcFunction);
```

---

### Lambda Layers

Lambda layers are ZIP archives mounted at `/opt` in the execution environment. Use them to share large dependencies (Prisma engine binaries, OTel SDK) across functions without duplicating them in each deployment package:

```ts
// In CDK stack
const prismaLayer = new lambda.LayerVersion(this, 'PrismaLayer', {
  code: lambda.Code.fromAsset('layers/prisma'),
  compatibleRuntimes: [lambda.Runtime.NODEJS_20_X],
  compatibleArchitectures: [lambda.Architecture.ARM_64],
  description: 'Prisma Client and query engine binaries',
});

trpcFunction.addLayers(prismaLayer);
```

The layer contents are available at `/opt/nodejs/node_modules` in the Lambda environment, which Node.js includes in its module resolution path.

---

### Cold Start Mitigation

**Provisioned Concurrency** — keeps a configured number of Lambda instances pre-initialized, eliminating cold starts for those instances:

```ts
// In CDK stack
const version = trpcFunction.currentVersion;

const alias = new lambda.Alias(this, 'LiveAlias', {
  aliasName: 'live',
  version,
  provisionedConcurrencyConfig: {
    provisionedConcurrentExecutions: 2,
  },
});
```

Provisioned Concurrency is billed even when idle. For cost efficiency, use Application Auto Scaling to scale provisioned concurrency based on schedule or metrics:

```ts
import * as appscaling from 'aws-cdk-lib/aws-applicationautoscaling';

const scalingTarget = new appscaling.ScalableTarget(this, 'ScalingTarget', {
  serviceNamespace: appscaling.ServiceNamespace.LAMBDA,
  resourceId: `function:${trpcFunction.functionName}:live`,
  scalableDimension: 'lambda:function:ProvisionedConcurrency',
  minCapacity: 1,
  maxCapacity: 10,
});

scalingTarget.scaleOnSchedule('ScaleUpMorning', {
  schedule: appscaling.Schedule.cron({ hour: '8', minute: '0' }),
  minCapacity: 3,
});

scalingTarget.scaleOnSchedule('ScaleDownNight', {
  schedule: appscaling.Schedule.cron({ hour: '22', minute: '0' }),
  minCapacity: 1,
});
```

**Minimize bundle size** — smaller packages initialize faster. Analyze with:

```bash
npx esbuild-visualizer --metadata dist/meta.json
```

**ARM64 architecture** — ARM Lambda functions (`graviton2`) typically initialize faster and cost less than x86_64 for equivalent memory configurations.

> [Inference] Cold start duration depends on bundle size, memory allocation, runtime, and whether the function is in a VPC. VPC-attached functions historically had longer cold starts; AWS has improved this with elastic network interface pre-allocation, but behavior may vary. These claims reflect general patterns, not guaranteed outcomes.

---

### Observability on Lambda

**CloudWatch Logs** — Lambda automatically streams stdout/stderr to CloudWatch. Structured JSON logs are parseable with CloudWatch Logs Insights:

```ts
// lib/logger.ts
export const logger = {
  info: (msg: string, data?: object) =>
    console.log(JSON.stringify({ level: 'info', msg, ...data })),
  error: (msg: string, data?: object) =>
    console.error(JSON.stringify({ level: 'error', msg, ...data })),
};
```

**AWS X-Ray** — AWS's native distributed tracing service. Enable active tracing on the Lambda function and instrument with the X-Ray SDK:

```ts
// CDK
const trpcFunction = new lambda.Function(this, 'TRPCHandler', {
  // ...
  tracing: lambda.Tracing.ACTIVE,
});
```

```ts
// src/handler.ts — X-Ray SDK
import AWSXRay from 'aws-xray-sdk-core';
import { PrismaClient } from '@prisma/client';

// Patch AWS SDK clients to auto-trace
AWSXRay.captureAWS(require('aws-sdk'));

// X-Ray creates subsegments for HTTP calls automatically when active tracing is on
```

**OTel on Lambda** — the AWS Distro for OpenTelemetry (ADOT) Lambda layer provides OTel instrumentation without bundling the SDK into the deployment package:

```ts
// CDK — add ADOT managed layer
import { AdotLambdaLayerGenericVersion, AdotLayerVersion, AdotLambdaExecWrapper } from 'aws-cdk-lib/aws-lambda';

const trpcFunction = new lambda.Function(this, 'TRPCHandler', {
  // ...
  adotInstrumentation: {
    layerVersion: AdotLayerVersion.fromGenericLayerVersion(
      AdotLambdaLayerGenericVersion.LATEST
    ),
    execWrapper: AdotLambdaExecWrapper.INSTRUMENT_HANDLER,
  },
});
```

> [Unverified] ADOT layer ARNs and `AdotLambdaLayerGenericVersion` enum values change with each release. Verify current values from the AWS ADOT documentation.

---

### Subscriptions on Lambda

API Gateway HTTP API does not support WebSockets. API Gateway WebSocket API is a separate product with a different event format and connection management model. tRPC's `applyWSSHandler` is not directly compatible with API Gateway WebSocket API's message-based model.

**Practical options:**

- **SSE via HTTP API** — tRPC's `httpSubscriptionLink` works within Lambda's execution duration limit. The invocation must complete before the timeout, limiting long-lived streams
- **Separate persistent server** — run a WebSocket-capable server on ECS Fargate, EC2, or AppRunner alongside the Lambda-based tRPC API; route subscriptions there via `splitLink`
- **AppSync** — AWS's managed GraphQL/WebSocket service; not directly compatible with tRPC without a translation layer

> [Inference] Lambda's execution model is fundamentally incompatible with indefinite WebSocket connections. Any subscription implementation on Lambda is bounded by the function timeout. For durable subscriptions, a persistent server is the more appropriate architectural choice.

---

### IAM Permissions

Lambda functions interact with AWS services via an IAM execution role. The CDK constructs grant permissions via methods on the resource:

```ts
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';

const bucket = new s3.Bucket(this, 'AssetsBucket');
const table = new dynamodb.Table(this, 'DataTable', {
  partitionKey: { name: 'pk', type: dynamodb.AttributeType.STRING },
});

// Grant specific permissions — avoid wildcards in production
bucket.grantReadWrite(trpcFunction);
table.grantReadWriteData(trpcFunction);
dbSecret.grantRead(trpcFunction);
```

---

### Common Issues on Lambda

| Symptom | Likely Cause |
|---|---|
| `Cannot find module '/var/task/...'` | Bundle missing a dependency — check `external` in esbuild config |
| Prisma engine not found | Binary target mismatch — set `binaryTargets` for Lambda architecture |
| `Task timed out after N seconds` | Procedure exceeds `timeout` — increase timeout or optimize the slow path |
| Database connection errors | No RDS Proxy or HTTP driver — Lambda exhausting database connection limit |
| Cold start > 5s | Bundle too large, VPC attachment, or large initialization in handler scope |
| CORS errors from browser | `traceparent` not in `allowHeaders` on API Gateway CORS config |
| `502 Bad Gateway` | Lambda returned a malformed response — check CloudWatch logs for the invocation |
| Secrets undefined | IAM role lacks `secretsmanager:GetSecretValue` permission |

---

### Deployment Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to AWS Lambda

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write   # required for OIDC auth to AWS
      contents: read

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - run: npm ci
      - run: npm test
      - run: npm run build

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/github-deploy-role
          aws-region: us-east-1

      - name: CDK deploy
        run: npx cdk deploy --require-approval never
```

OIDC-based authentication avoids long-lived AWS access keys in GitHub Secrets. The IAM role trusts GitHub's OIDC provider and grants only the permissions needed to deploy the CDK stack.

---

### Summary

| Concern | Approach |
|---|---|
| Adapter | `awsLambdaRequestHandler` from `@trpc/server/adapters/aws-lambda` |
| API Gateway | HTTP API v2 — lower latency and cost than REST API |
| Bundling | `esbuild` — single-file output, Prisma in layer |
| Infrastructure | AWS CDK in TypeScript |
| Database | RDS Proxy or HTTP-based driver (Neon, PlanetScale) |
| Secrets | Secrets Manager + `grantRead` IAM grant |
| Cold starts | Provisioned Concurrency, ARM64, minimal bundle |
| Tracing | ADOT Lambda layer (OTel) or X-Ray active tracing |
| Subscriptions | SSE within timeout, or persistent server via `splitLink` |
| CI/CD | GitHub Actions + OIDC + `cdk deploy` |

**Next Steps:**
- Configure Lambda function URLs as an alternative to API Gateway for lower latency and simpler setup when advanced routing is not needed
- Add a CloudWatch dashboard with Lambda-specific metrics (`Duration`, `Errors`, `Throttles`, `ConcurrentExecutions`) alongside tRPC procedure metrics from structured logs
- Evaluate AWS AppRunner or ECS Fargate for tRPC deployments that require WebSocket subscriptions, as a persistent-server alternative within the AWS ecosystem