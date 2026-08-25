## Overview

open build/coverage/index.html
```

### Continuous Integration

Tests run automatically on:

- Every commit to develop branch
- Pull requests to main branch
- Nightly builds for all supported platforms

## Contributing

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes following the coding standards
4. Add tests for new functionality
5. Run the test suite: `make test`
6. Commit your changes: `git commit -m 'Add amazing feature'`
7. Push to your branch: `git push origin feature/amazing-feature`
8. Create a Pull Request

### Coding Standards

- Follow K&R C style with 4-space indentation
- Maximum line length: 80 characters
- Function names: `module_operation` format
- Variable names: `snake_case`
- Constants: `UPPER_CASE`
- All public functions must have Doxygen documentation
- Every module must have comprehensive unit tests

### Code Review Process

1. All changes require peer review
2. Must pass automated tests
3. Must maintain test coverage above 90%
4. Documentation must be updated for API changes
5. Performance impact must be assessed for core functions

## Architecture

### High-Level Design

```
┌─────────────────────┐
│   User Interface    │
├─────────────────────┤
│  Business Logic     │
├─────────────────────┤
│   Data Access       │
├─────────────────────┤
│   Persistence       │
└─────────────────────┘
```

### Module Structure

- `core/`: Business logic and domain models
- `data/`: Data access and persistence layers
- `ui/`: User interface implementations
- `utils/`: Utility functions and helpers
- `tests/`: Test suites and test data

## Performance Characteristics

### Time Complexity

- Book search: O(n) linear search, O(log n) with indexing
- Add/Remove operations: O(1) amortized
- Report generation: O(n) where n is relevant record count

### Memory Usage

- Base system: ~5MB
- Per book record: ~512 bytes
- Per user record: ~256 bytes
- Search results: Temporary allocation proportional to matches

### Scalability Limits

- Maximum books: 100,000 (configurable)
- Maximum concurrent users: 10,000 (configurable)
- Maximum search results: 1,000 per query

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

- **Project Lead**: development-team@library-system.org
- **Bug Reports**: https://github.com/organization/library-system/issues
- **Documentation**: https://docs.library-system.org
- **Support**: support@library-system.org

````

