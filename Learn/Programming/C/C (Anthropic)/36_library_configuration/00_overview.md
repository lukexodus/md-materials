## Overview

[database]
data_directory = /var/lib/library
backup_directory = /var/backup/library
max_books = 100000
max_users = 10000

[borrowing]
loan_period_days = 14
max_renewals = 2
fine_per_day = 0.25
max_fine_amount = 10.00

[system]
log_level = INFO
log_file = /var/log/library.log
enable_statistics = true
```

## API Documentation

Full API documentation is available in the `docs/` directory or can be generated using:

```bash
make docs
```

### Quick Reference

```c
#include "library_system.h"

// Initialize system
LibrarySystem* system = library_system_create();

// Basic operations
library_borrow_book(system, user_id, book_id);
library_return_book(system, user_id, book_id);
library_calculate_fines(system, user_id);

// Cleanup
library_system_destroy(system);
```

## Testing

### Running Tests

```bash
