Whenever adopting any new software products there are operational considerations. Particularly in the case of HashiCorp Vault, a centralised secret management solution is a double edge sword, where the security is only as good as the governance around it.
 
Maintaining a complex set of policies in Vault generally requires collaboration within a number of personas:
A developer, or application architect, that requires access to a set of secrets.
A security officer, that reviews the policy and ultimately approves access.
An operator, that generally implements the policy.
A compliance officer, or auditor, that needs full traceability on the what, how and when policies were changed.
Above all things, policy changes need to be enforced, auditable, and easily tested. Policy needs to be versioned, and stored in a way where it can be underestimated easy scrutiny, because in this case, the more exposure policy gets, the easier to find problems with it.
There is the need for a tool that can be imperative when it comes to policy, that can take any version of the policy and quickly evaluate the differences between the actual state and the desired state.
Finally, in an agile world, we need a way to ensure that policy can be evaluated quickly and integrated into Vault, reducing the time between the requirement and the implementation. Ideally, we would need to implement a workflow in software that allows to quickly request, validate, integrate, and push policy changes reducing the possibility of failures to be introduced while keeping a close loop.
 
Luckily, we have all the tools we need for that:
 
The ideal tool to maintain the policy and request policy, would be of course an SCM or Version Control System, such as GitHub, GitLab, or BitBucket, among others. Primarily due to the fact that it would allow to keep a full history of all the changes introduced in policy throughout time, or even rollback to a specific version, but also due to the fact that is the main tool that developers use. So it would be quite familiar to them requesting policy changes through pull requests in Version Control.
Potentially merge control can be given to the security officer, in order to simply read the changes and decide if they would be allowed or not.
A continuous integration tool, such as Jenkins, Teamcity, Travis or Bamboo, among others would be able to do basic parsing validation into the policy, as well as catch potentially offending policies through the use of regular expressions. Ultimately, it can deploy the policy to Vault.
The recent release of a vault_policy resource in Terraform makes it an ideal candidate to carry out the deployment for a number of reasons.
The imperative nature of Terraform, ensures that the policy in Vault will always match what’s described in version control.
As Terraform maintains a state, it can evaluate the changes and provide a detailed change set of the actions that will be carried out.
Terraform will fail verbosely in case the policy is not applied.
Through the use of terraform dry-runs (terraform plan), we can quickly evaluate if the running policy is compliant with what’s declared in Version Control without introducing any changes to the running policy for audit reasons.
An auditor can simply run terraform plan to evaluate if the Vault Cluster is compliant. The CI tool can run terraform plan on a schedule to ensure that changes to the policy weren’t introduced manually.
 
An example of this implementation can be found on this version control repository which contains this Jenkinsfile. In this case, the end to end workflow is described in a Jenkins Pipeline with the following steps:
 
- Validation: Do a parsing check on the terraform files and the policy.
- Security check: Ensure that policy is not granting access to /sys, as an example, which is the path used for operational information in Vault (including policy). This is done at this time through the use of regular expressions.
- Obtain a token: Using Approle, obtain a short lived token that allows the process to read/write policy (and only policy) into Vault.
- Plan: Do a dry run to review the changes.
- Approve: Manual intervention to approve the change based on the dry run.
- Apply: Implement the changes into Vault.
- Revoke: Revoke the token used for the operation.

