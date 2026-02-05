# Contributing to Ada-SPARK-Best-Practices

Thank you for your interest in contributing to Ada-SPARK-Best-Practices! We welcome contributions from everyone and appreciate your effort to make this project better.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Developer Certificate of Origin](#developer-certificate-of-origin)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing to ensure a welcoming and inclusive environment for everyone.


## How to Contribute

This repository contains a series of sample code in both C and SPARK in various
categories. Contributions are always welcome, please review the categories to 
see where your contribution best fits and then follow the structure of other
sample code in that category. Especially for LLMs it is important to be
descriptive in your explanation and provide that explanation in textual format.


### Reporting Bugs

Before creating a bug report:
- Check the [issue tracker](https://github.com/org/project/issues) to avoid duplicates
- Use the latest version to verify the bug still exists

When creating a bug report, include:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected vs. actual behavior
- Your environment (OS, version, etc.)
- Any relevant logs or error messages

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:
- Use a clear, descriptive title
- Provide a detailed description of the proposed functionality
- Explain why this enhancement would be useful
- List any alternative solutions you've considered

### Contributing Code

1. **Find or create an issue** - Check existing issues or create a new one to discuss your proposed changes
2. **Create a branch** - Make your changes in a new git branch:
```bash
   git checkout -b feature/your-feature-name
```
3. **Make your changes** - Follow our [coding standards](#coding-standards)
4. **Test your changes** - Ensure all tests pass and add new tests if needed
5. **Commit your changes** - Follow our [commit guidelines](#commit-guidelines)
6. **Sign off your commits** - See [Developer Certificate of Origin](#developer-certificate-of-origin)
7. **Push to your fork**:
```bash
   git push origin feature/your-feature-name
```
8. **Open a Pull Request** - Follow our [PR process](#pull-request-process)

## Developer Certificate of Origin

This project uses the Developer Certificate of Origin (DCO) to ensure that contributors have the legal right to submit their contributions. The DCO is a lightweight way for you to certify that you wrote or have the right to submit the code you are contributing.

### The DCO Text

By making a contribution to this project, you certify that:
```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

### How to Sign Off Your Commits

To sign off on a commit, add the following line at the end of your commit message:
```
Signed-off-by: Your Name <your.email@example.com>
```

You can do this automatically by using the `-s` or `--signoff` flag with `git commit`:
```bash
git commit -s -m "Your commit message"
```

Git will automatically add the sign-off line using your configured name and email.

### Ensuring All Commits Are Signed Off

Every commit in your pull request must include a DCO sign-off. If you forget to sign off on a commit, you can amend it:
```bash
# For the most recent commit
git commit --amend --signoff

# For multiple commits, rebase and sign off
git rebase --signoff HEAD~<number-of-commits>

# Then force push (be careful!)
git push --force-with-lease
```

### DCO Enforcement

All pull requests are automatically checked for DCO sign-offs. PRs without proper sign-offs on all commits will not be merged until this requirement is satisfied.

## Coding Standards

Please follow these coding standards to maintain consistency across the project:

### General Guidelines

- Write clear, readable code with meaningful variable and function names
- Add comments to explain complex logic, but prefer self-documenting code
- Keep functions small and focused on a single responsibility
- Follow the [style guide/formatter used, e.g., rustfmt, black, prettier]

### Documentation

- Update documentation for any changed functionality
- Update README.md if adding new features
- Keep CHANGELOG.md updated (if applicable)

## Commit Guidelines

### Commit Message Format

Follow this format for commit messages:
```
<type>: <short summary>

<optional body>

<optional footer>

Signed-off-by: Your Name <your.email@example.com>
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring without changing functionality
- `ci`: CI/CD configuration changes

### Examples
```
feat: add support for custom configuration files

Implements the ability to load settings from YAML configuration files.
This allows users to customize behavior without modifying code.

Closes #123

Signed-off-by: Jane Developer <jane@example.com>
```
```
fix: resolve memory leak in connection pooling

The connection pool was not properly releasing connections after errors,
causing gradual memory exhaustion over time.

Signed-off-by: John Contributor <john@example.com>
```

## Pull Request Process

1. **Ensure your PR addresses an existing issue** - Reference the issue number in your PR description
2. **Update documentation** - Include any necessary documentation updates
3. **Add/update tests** - Ensure your changes are covered by tests
4. **Verify all commits are signed off** - The DCO check must pass
5. **Ensure CI passes** - All automated checks must be green
6. **Request review** - Tag appropriate reviewers or wait for automatic assignment
7. **Address feedback** - Respond to review comments and update your PR as needed
8. **Squash commits if requested** - Maintain a clean commit history

### PR Description Template

When opening a PR, please include:
```markdown
## Description
[Describe what this PR does]

## Related Issue
Fixes #[issue number]

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update

## Testing
[Describe the tests you ran and how to reproduce them]

## Checklist
- [ ] All commits are signed off (DCO)
```


### Recognition

We value all contributions! 


Thank you for contributing to [Ada-SPARK-Best-Practices]! 