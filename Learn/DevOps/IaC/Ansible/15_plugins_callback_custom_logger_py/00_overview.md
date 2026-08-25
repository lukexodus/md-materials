## Overview


from ansible.plugins.callback import CallbackBase
import json
import requests
import datetime

class CallbackModule(CallbackBase):
    """Custom callback plugin for external logging"""
    
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'custom_logger'
    CALLBACK_NEEDS_WHITELIST = True
    
    def __init__(self):
        super(CallbackModule, self).__init__()
        self.webhook_url = self._get_option('webhook_url')
        self.log_level = self._get_option('log_level', 'info')
        
    def _send_notification(self, event_type, data):
        """Send notification to external system"""
        payload = {
            'timestamp': datetime.datetime.utcnow().isoformat(),
            'event_type': event_type,
            'data': data
        }
        
        try:
            response = requests.post(
                self.webhook_url,
                json=payload,
                timeout=10
            )
            response.raise_for_status()
        except requests.exceptions.RequestException as e:
            self._display.warning(f"Failed to send notification: {str(e)}")
    
    def v2_playbook_on_start(self, playbook):
        """Called when playbook starts"""
        if self.webhook_url:
            self._send_notification('playbook_start', {
                'playbook': playbook._file_name
            })
    
    def v2_playbook_on_stats(self, stats):
        """Called when playbook completes"""
        if self.webhook_url:
            summary = {}
            for host in stats.processed.keys():
                summary[host] = stats.summarize(host)
            
            self._send_notification('playbook_complete', {
                'stats': summary
            })
    
    def v2_runner_on_failed(self, result, ignore_errors=False):
        """Called when task fails"""
        if self.webhook_url and self.log_level in ['debug', 'info']:
            self._send_notification('task_failed', {
                'host': result._host.get_name(),
                'task': result._task.get_name(),
                'error': result._result.get('msg', 'Unknown error')
            })
```

**Advanced Plugin Features:**

**Configuration Options:**

```python
