## Overview


from ansible.plugins.lookup import LookupBase
from ansible.errors import AnsibleError, AnsibleParserError
import mysql.connector
import json

class LookupModule(LookupBase):
    
    def run(self, terms, variables=None, **kwargs):
        """Execute database lookup"""
        
        # Parse connection parameters
        connection_params = {
            'host': kwargs.get('host', 'localhost'),
            'port': kwargs.get('port', 3306),
            'user': kwargs.get('user', 'root'),
            'password': kwargs.get('password', ''),
            'database': kwargs.get('database', ''),
        }
        
        results = []
        
        try:
            # Establish database connection
            connection = mysql.connector.connect(**connection_params)
            cursor = connection.cursor(dictionary=True)
            
            for term in terms:
                # Execute query
                cursor.execute(term)
                query_results = cursor.fetchall()
                results.extend(query_results)
            
            cursor.close()
            connection.close()
            
        except mysql.connector.Error as e:
            raise AnsibleError(f"Database query failed: {str(e)}")
        
        except Exception as e:
            raise AnsibleError(f"Lookup plugin error: {str(e)}")
        
        return results
```

**Lookup Plugin Usage:**

```yaml
---
- name: Query database for user information
  set_fact:
    user_data: "{{ lookup('database_lookup', 'SELECT * FROM users WHERE active = 1', 
                         host='db.example.com', 
                         user='ansible', 
                         password='{{ vault_db_password }}',
                         database='application') }}"

- name: Display user information
  debug:
    msg: "Found {{ user_data | length }} active users"
```

**Callback Plugin Development:**

Callback plugins respond to execution events for logging, monitoring, and integration purposes:

```python
