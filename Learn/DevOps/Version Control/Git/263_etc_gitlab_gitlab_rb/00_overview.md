## Overview

gitlab_rails['backup_path'] = '/var/opt/gitlab/backups'
gitlab_rails['backup_archive_permissions'] = 0644
gitlab_rails['backup_keep_time'] = 604800  # 1 week in seconds
gitlab_rails['backup_upload_connection'] = {
  'provider' => 'AWS',
  'region' => 'us-east-1',
  'aws_access_key_id' => 'AKIAXXXXXXXXXXXXXXXX',
  'aws_secret_access_key' => 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
}
gitlab_rails['backup_upload_remote_directory'] = 'gitlab-backups'
```

#### Git Repository Mirroring

```bash
