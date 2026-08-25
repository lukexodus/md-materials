## Custom Plugin Development


Standard plugins may miss domain-specific risks (e.g., proprietary internal APIs that are known to be unsafe). Custom plugins allow you to extend Bandit's AST traversal logic.

Plugin Anatomy:

A plugin is a Python function decorated with @bandit.checks. It must accept context (the AST node wrapper) and return bandit.Issue if a violation is found.

Example: Detecting Internal Insecure API Usage

Scenario: Your org has a deprecated internal method legacy_crypto.encrypt that must be flagged.

Python

```
import bandit
from bandit.core import test_properties as test

@test.checks('Call')
@test.test_id('B901')
def check_legacy_crypto_usage(context):
    # Check if the call is to legacy_crypto.encrypt
    if context.call_function_name_qual == 'legacy_crypto.encrypt':
        return bandit.Issue(
            severity=bandit.HIGH,
            confidence=bandit.HIGH,
            text="Use of deprecated 'legacy_crypto.encrypt' detected. "
                 "Migrate to 'modern_crypto.aead_encrypt'."
        )
```

Registration:

This plugin must be registered via setuptools entry points in your internal tooling package setup.py:

Python

```
entry_points={
    'bandit.plugins': [
        'check_legacy_crypto = my_security_package.checks:check_legacy_crypto_usage',
    ],
}
```

