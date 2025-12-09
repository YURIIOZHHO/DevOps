### Simple CI/CD project

#### This project demonstrates a minimal CI/CD setup using GitHub Actions. It includes two workflows that perform automated testing, conditional deployment, and environment inspection.

#### main.yaml — Automated Test & Deploy Pipeline
#### This workflow runs automatically on every push.
#### It performs two sequential jobs:
##### Job 1: Test
##### 1. Checks out the repository
##### 2. Installs Node.js (v18)
##### 3. Installs dependencies via npm ci
##### 4. Runs tests using npm test 

```yaml:
name: base github-action
on: push
jobs:
  first-job-with-test:
    runs-on: ubuntu-latest

    steps:
    - name: add code
      uses: actions/checkout@v4

    - name: install node
      uses: actions/setup-node@v4
      with:
        node-version: 18
      
    - name: install dependecies
      run: npm ci

    - name: start test
      run: npm test
```

##### Job 2: Deploy (runs only if tests pass)
##### Depends on job 1 via needs.
##### Simulates deployment by printing a deployment message.

```yaml
  second-job-with-deploy:
    needs: first-job-with-test
    runs-on: ubuntu-latest

    steps:
    - name: to deploy code on server
      uses: actions/checkout@v4

    - name: to intall node
      uses: actions/setup-node@v4
      with:
        node-version: 18
    
    - name: install dependencies
      run: npm ci
    
    - name: deploy on server
      run: echo "Deploy on server..."
```

#### Successful run example
!["Successful run example"](https://github.com/user-attachments/assets/4ad1390e-f830-458e-bee2-c03d9fb3f49c)

#### info.yaml — GitHub Context Inspector
##### This workflow is triggered manually (workflow_dispatch).
##### It outputs the entire GitHub Actions context object, which is useful for debugging, learning, and workflow development.
```yaml
name: Get all info
on: workflow_dispatch
jobs:
  get-info:
    runs-on: ubuntu-latest

    steps:
    - name: Output GitHub info
      run: echo "${{ toJson(github) }}"
```

#### Example output:
!["Example output"](https://github.com/user-attachments/assets/75d6ed48-6d00-42b0-ad85-f77a0ab75783)
