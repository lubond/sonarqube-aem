# sonarqube-aem

This is a docker image that is identical to the official [SonarQube 9 Community Docker image](https://github.com/SonarSource/docker-sonarqube/blob/master/9/community/Dockerfile) with added scripts to install the [AEM-Rules for SonarQube](https://github.com/Cognifide/AEM-Rules-for-SonarQube) extension.

## Running

Latest from Docker Hub:

```sh
docker run --rm -p 9000:9000 lubond/sonarqube-aem:latest
```

From Source:

Clone the repo and run the `build-and-run-container.sh` script. Or open it and run the commands manually. Sonar will run on port 9000.

## Custom Quality Gates

Take a look at `quality.sh` in source code and adjust it to your needs.

By default, that script will create a new `aem-gate` Gate and set the following Conditions:

| Quality Requirement | Threshold |
|--|:--:|
| Code Coverage | 80% |
| Code Smells | A |
| Maintainability Rating | A |
| Reliability Rating | A |
| Security Rating | A |
