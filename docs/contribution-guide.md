# Contribution Guide

Thank you for considering contributing to Sake! To ensure a smooth collaboration, please follow the guidelines below before submitting your Pull Request:

### Before Writing Code

We kindly ask that you open a discussion or issue first to discuss your proposed changes. This helps ensure your time is well-spent on features or fixes that align with the project's direction and prevents duplicate efforts.

### Code Formatting and Testing

Before committing your code and opening a Pull Request, make sure to:

- Run code formatting:
  ```bash
  sake format
  ```
- Run all tests to ensure everything is working as expected:
  ```bash
  sake test
  ```

### Commit Message Convention

Please use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for naming your commit messages. However, it's not required for every commit, as commits will be squashed upon merge, and the title of the Pull Request will be used. Therefore, this naming rule applies mainly to Pull Request titles.

The following groups are used in this project:

- `feat`: Features
- `fix`: Bug Fixes
- `test`: Testing
- `perf`: Performance
- `refactor`: Refactoring
- `doc`: Documentation
- `project`: Project changes

If you do not use any of these categories in your Pull Request title, it will be placed in the "Other" group.

Here's an example of a proper Pull Request title:

```bash
feat: add support for new configuration option
```

Feel free to reach out if you have any questions or need further clarification.
