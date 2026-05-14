---
name: terraform-test
description: "Comprehensive guide for writing and running Terraform tests using .tftest.hcl files, run blocks, assertions, mock providers, plan mode and apply mode testing, and CI/CD integration. Use when creating test files, writing test scenarios, validating infrastructure behavior, or troubleshooting Terraform test syntax and execution. Do not use for Terratest (Go-based) testing or general Terraform configuration."
---

# Terraform Test

Terraform's built-in testing framework enables module authors to validate that configuration updates don't introduce breaking changes. Tests execute against temporary resources, protecting existing infrastructure and state files.

## Core Concepts

**Test File**: A `.tftest.hcl` or `.tftest.json` file containing test configuration and run blocks that validate your Terraform configuration.

**Test Block**: Optional configuration block that defines test-wide settings (available since Terraform 1.6.0).

**Run Block**: Defines a single test scenario with optional variables, provider configurations, and assertions. Each test file requires at least one run block.

**Assert Block**: Contains conditions that must evaluate to true for the test to pass. Failed assertions cause the test to fail.

**Mock Provider**: Simulates provider behavior without creating real infrastructure (available since Terraform 1.7.0).

**Test Modes**: Tests run in apply mode (default, creates real infrastructure) or plan mode (validates logic without creating resources).

## File Structure

Terraform test files use the `.tftest.hcl` or `.tftest.json` extension and are typically organized in a `tests/` directory. Use clear naming conventions to distinguish between unit tests (plan mode) and integration tests (apply mode):

```
my-module/
+-- main.tf
+-- variables.tf
+-- outputs.tf
+-- tests/
    +-- validation_unit_test.tftest.hcl      # Unit test (plan mode)
    +-- edge_cases_unit_test.tftest.hcl      # Unit test (plan mode)
    +-- full_stack_integration_test.tftest.hcl  # Integration test (apply mode)
```

## Test Execution

### Running Tests

```bash
terraform test                              # Run all tests
terraform test tests/defaults.tftest.hcl    # Run specific test file
terraform test -verbose                     # Run with verbose output
terraform test -filter=test_vpc             # Filter tests by name
terraform test -no-cleanup                  # Keep resources for debugging
```

## Best Practices

1. **Test Organization**: Use `*_unit_test.tftest.hcl` for plan mode, `*_integration_test.tftest.hcl` for apply mode
2. **Apply vs Plan**: Use `command = plan` for unit tests (fast, free); `command = apply` for integration tests
3. **Meaningful Assertions**: Write clear, specific assertion error messages
4. **Mock Providers**: Use mocks for external dependencies (requires Terraform 1.7.0+)
5. **Negative Testing**: Test invalid inputs using `expect_failures`
6. **Parallel Execution**: Use `parallel = true` for independent tests with different state files

## References

For more information:
- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Terraform Test Command Reference](https://developer.hashicorp.com/terraform/cli/commands/test)
- [Testing Best Practices](https://developer.hashicorp.com/terraform/language/tests/best-practices)
