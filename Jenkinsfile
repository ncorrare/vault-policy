def projectProperties = [
    [$class: 'BuildDiscarderProperty',strategy: [$class: 'LogRotator', numToKeepStr: '3']],
]
properties(projectProperties)
pipeline {
  agent any
  stages { 
    stage('Prepare environment') {
      steps {
        sh '''
        curl -o vault.zip https://releases.hashicorp.com/vault/${vault_version}/vault_${vault_version}_linux_arm.zip ; yes | unzip vault.zip
        curl -o terraform.zip https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_arm.zip ; yes | unzip terraform.zip
        rm -rf terraform.zip
        rm -rf vault.zip
        '''
      }
    }  
    stage('Validation') {
      steps {
        sh './terraform validate'
      }
    }
    stage('Policy Validation') {
      steps {
        sh '''
        #!/bin/bash
        set -e
        ### Ensure that no policy contains permissions on sys/ with the exception of the base policy-edit.
        grep -rq --exclude=README --exclude=terraform --exclude=vault --exclude=Jenkinsfile --exclude=vault_policies.tf sys * && echo "Potentially offending policy" && /bin/false || echo "Policy ok" && /bin/true
        '''
      }
    }
    stage('Obtain Vault Token') {
      steps {
        withCredentials([string(credentialsId: 'role', variable: 'ROLE_ID'),string(credentialsId: 'VAULTTOKEN', variable: 'VAULT_TOKEN')]) {
        sh '''
          set -x
          curl https://raw.githubusercontent.com/ncorrare/vault-java-example/master/ca.crt > ca.crt
          export VAULT_CACERT=$(pwd)/ca.crt
          export VAULT_ADDR=https://vault.service.lhr.consul:8200
          export SECRET_ID=$(./vault write -field=secret_id -f auth/approle/role/java-example/secret-id)
          export VAULT_TOKEN=$(./vault write -field=token auth/approle/login role_id=${ROLE_ID} secret_id=${SECRET_ID})
          echo $VAULT_TOKEN > ~/.vault-token
          '''
        }
      }
    }    
    stage('Dry Run') {
      steps {
        sh './terraform plan'
      }
    }
    stage('Apply policy') {
      steps {
       sh './terraform apply'
      }
    }
  }  
  environment {
    terraform_version = '0.9.4'
    VAULT_ADDR        = 'https://vault.service.lhr.consul:8200/'
    vault_version     = '0.7.0'
  }
}                     