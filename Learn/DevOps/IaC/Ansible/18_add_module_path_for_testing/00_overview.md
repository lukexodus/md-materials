## Overview

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'library'))

from custom_service_manager import ServiceManager, main

class TestServiceManager(unittest.TestCase):
    
    def setUp(self):
        """Set up test fixtures"""
        self.mock_module = MagicMock()
        self.mock_module.params = {
            'name': 'test_service',
            'state': 'started',
            'config_file': '/etc/test/config.yml'
        }
        self.service_manager = ServiceManager(self.mock_module)
    
    def test_service_start_success(self):
        """Test successful service start"""
        with patch('subprocess.run') as mock_run:
            mock_run.return_value.returncode = 0
            mock_run.return_value.stdout = "Service started successfully"
            
            result = self.service_manager.start_service()
            
            self.assertTrue(result['changed'])
            self.assertIn('started', result['msg'])
    
    def test_service_start_failure(self):
        """Test service start failure handling"""
        with patch('subprocess.run') as mock_run:
            mock_run.return_value.returncode = 1
            mock_run.return_value.stderr = "Service start failed"
            
            with self.assertRaises(Exception):
                self.service_manager.start_service()
    
    def test_parameter_validation(self):
        """Test parameter validation logic"""
        invalid_params = {
            'name': '',  # Empty service name
            'state': 'invalid_state',
            'config_file': '/nonexistent/path'
        }
        
        with self.assertRaises(ValueError):
            ServiceManager.validate_parameters(invalid_params)
    
    @patch('os.path.exists')
    def test_config_file_validation(self, mock_exists):
        """Test configuration file validation"""
        mock_exists.return_value = False
        
        result = self.service_manager.validate_configuration()
        
        self.assertFalse(result['valid'])
        self.assertIn('not found', result['message'])

if __name__ == '__main__':
    unittest.main()
```

**Integration Testing:**

**Molecule Framework** provides comprehensive integration testing for Ansible content:

```yaml
