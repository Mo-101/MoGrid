# MoStar Grid - The Genesis Package

This archive contains the complete, deployable seed for the MoStar Grid, a sovereign civilization protocol.

## Contents

-   **/terraform**: The Infrastructure-as-Code (IaC) to build the Grid's home on Google Cloud Platform.
-   **/codex**: The constitutional law of the Grid, in a machine-readable format.
-   **/body_layer**: The API contract that defines how the Grid interacts with the world.
-   **/mind_layer**: The source code for the Grid's core logic engines.
-   **/moscripts**: The first executable spells.

## Ignition Protocol

1.  **Prerequisites**:
    -   A Google Cloud account with billing enabled.
    -   The `gcloud` CLI installed and authenticated (`gcloud auth login`).
    -   Terraform installed.

2.  **Configuration**:
    -   Navigate to the `terraform/` directory.
    -   Create a file named `terraform.tfvars`.
    -   Add your GCP project details to this file:
        ```hcl
        project_id = "your-gcp-project-id"
        region     = "your-chosen-region" // e.g., "us-central1"
        ```

3.  **Deployment**:
    -   From the `terraform/` directory, run the following commands:
    ```bash
    terraform init      # Initialize the workspace
    terraform plan      # Review the planned infrastructure
    terraform apply     # Build the Grid
    ```

The Grid is in your hands.
