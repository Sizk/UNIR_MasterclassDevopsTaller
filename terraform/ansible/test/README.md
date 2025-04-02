# Ansible Playbook Testing Environment

This directory contains Docker configurations to test the Ansible playbook locally before deploying to AWS and Azure.

## Why Test Locally?

Testing your Ansible playbooks locally before deploying to the cloud offers several benefits:

1. **Faster feedback cycle**: No need to wait for cloud resources to provision
2. **Cost savings**: Avoid creating and destroying cloud resources during development
3. **Easier debugging**: Direct access to logs and containers
4. **Consistent testing environment**: Same environment for all developers
5. **Verify multi-platform compatibility**: Test on both AWS and Azure-like environments

## How It Works

The testing environment uses Docker to simulate both AWS and Azure environments:

- **AWS Environment**: Uses Amazon Linux 2 as the base image
- **Azure Environment**: Uses Ubuntu 20.04 as the base image

Both environments:
- Have Ansible pre-installed
- Mount your playbook and templates from the parent directory
- Run the playbook against localhost
- Start the web server to verify the results

## Usage

### Prerequisites

- Docker and Docker Compose installed on your machine

### Running the Tests

1. Navigate to this directory:
   ```
   cd ansible/test
   ```

2. Make the test script executable:
   ```
   chmod +x test-playbook.sh
   ```

3. Run the test script:
   ```
   ./test-playbook.sh
   ```

4. Access the test webservers:
   - AWS: http://localhost:8080
   - Azure: http://localhost:8081

### Stopping the Tests

To stop the test containers:
```
docker-compose down
```

## Troubleshooting

If you encounter issues:

1. Check the container logs:
   ```
   docker logs aws-webserver-test
   docker logs azure-webserver-test
   ```

2. Access a running container for debugging:
   ```
   docker exec -it aws-webserver-test bash
   docker exec -it azure-webserver-test bash
   ```

3. Verify your playbook syntax:
   ```
   ansible-playbook --syntax-check ../webserver_setup.yml
   ```

## Extending the Tests

You can modify the `docker-compose.yml` file to:
- Test with different OS versions
- Add more test scenarios
- Simulate different network conditions
- Add automated tests for your webserver
