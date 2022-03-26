# Hello cdk8s

Created as follows, and then completed following the [cdk8s tutorial](https://cdk8s.io/docs/latest/getting-started).

```bash
$ cdk8s init go-app
Initializing a project from the go-app template
Importing k8s v1.22.0...
Importing resources, this may take a few moments...
go: downloading github.com/cdk8s-team/cdk8s-core-go/cdk8s v1.5.50
go: downloading github.com/aws/constructs-go/constructs/v3 v3.3.248
go: downloading github.com/aws/jsii-runtime-go v1.55.1
go: downloading github.com/Masterminds/semver/v3 v3.1.1
========================================================================================================

 Your cdk8s Go project is ready!

   cat help      Prints this message  
   cdk8s synth   Synthesize k8s manifests to dist/
   cdk8s import  Imports k8s API objects to "imports/k8s"

  Deploy:
   kubectl apply -f dist/

========================================================================================================
```
