package test

import (
	"math/rand"
	"strconv"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestExamplesComplete(t *testing.T) {
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
	}

	terraform.Init(t, terraformOptions)
	// Run tests in parallel
	t.Run("Enabled", testExamplesCompleteEnabled)
	t.Run("S3Integration", testExamplesS3Integration)
}

func testExamplesCompleteEnabled(t *testing.T) {
	t.Parallel()

	rand.Seed(time.Now().UnixNano())

	randId := strconv.Itoa(rand.Intn(100000))
	attributes := []string{randId}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		EnvVars: map[string]string{
			"TF_CLI_ARGS": "-state=terraform-enabled-test.tfstate",
		},
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform apply` and fail the test if there are any errors
	terraform.Apply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "172.16.0.0/16", vpcCidr)

	// Run `terraform output` to get the value of an output variable
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.0.0/19", "172.16.32.0/19"}, privateSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.96.0/19", "172.16.128.0/19"}, publicSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	instanceId := terraform.Output(t, terraformOptions, "instance_id")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-ue2-test-rds-"+randId, instanceId)

	// Run `terraform output` to get the value of an output variable
	optionGroupId := terraform.Output(t, terraformOptions, "option_group_id")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, optionGroupId, "eg-ue2-test-rds")

	// Run `terraform output` to get the value of an output variable
	parameterGroupId := terraform.Output(t, terraformOptions, "parameter_group_id")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, parameterGroupId, "eg-ue2-test-rds")

	// Run `terraform output` to get the value of an output variable
	subnetGroupId := terraform.Output(t, terraformOptions, "subnet_group_id")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-ue2-test-rds-"+randId, subnetGroupId)
}

func testExamplesS3Integration(t *testing.T) {
	t.Parallel()

	rand.Seed(time.Now().UnixNano() + 1)

	randId := strconv.Itoa(rand.Intn(100000))
	attributes := []string{randId}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		Upgrade:      true,
		EnvVars: map[string]string{
			"TF_CLI_ARGS": "-state=terraform-s3-integration-test.tfstate",
		},
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"s3-integration.us-east-2.tfvars"},
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform apply` and fail the test if there are any errors
	terraform.Apply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "172.16.0.0/16", vpcCidr)

	// Run `terraform output` to get the value of an output variable
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.0.0/19", "172.16.32.0/19"}, privateSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, []string{"172.16.96.0/19", "172.16.128.0/19"}, publicSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	instanceId := terraform.Output(t, terraformOptions, "instance_id")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-ue2-test-rds-s3-integration-"+randId, instanceId)

	// Run `terraform output` to get the value of an output variable
	optionGroupId := terraform.Output(t, terraformOptions, "option_group_id")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, optionGroupId, "eg-ue2-test-rds-s3-integration")

	// Run `terraform output` to get the value of an output variable
	parameterGroupId := terraform.Output(t, terraformOptions, "parameter_group_id")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, parameterGroupId, "eg-ue2-test-rds-s3-integration")

	// Run `terraform output` to get the value of an output variable
	subnetGroupId := terraform.Output(t, terraformOptions, "subnet_group_id")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "eg-ue2-test-rds-s3-integration-"+randId, subnetGroupId)

	// Run `terraform output` to get the value of an output variable
	roleAssociations := terraform.Output(t, terraformOptions, "role_associations")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, "S3_INTEGRATION", roleAssociations)
}
