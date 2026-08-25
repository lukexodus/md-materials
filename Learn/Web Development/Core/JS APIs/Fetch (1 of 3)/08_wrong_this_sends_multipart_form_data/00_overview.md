## Overview

files = {'image': open('image.jpg', 'rb')}
data = {'model': 'claude-sonnet-4-20250514'}
requests.post(url, files=files, data=data)

