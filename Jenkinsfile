// Load in the shared platform jenkins DSL utilities
@Library('platform') _
def repo_version = '0.0.0'
def product = 'ncr_dfw_tcagent_build'
def repo = 'platform' // the product name and the repo name will be the same for the majority of applications. The repo determins the base folder used in Artifactory.
def version(file) {
  def matcher = readFile(file) =~ '"(.+)"'
  matcher ? matcher[0][1] : null
}

node('windows'){
  checkout scm
  stage('Package and Archive'){
    execute "chef exec rake release:bump:patch release:bundle"
    repo_version = version("./VERSION")
    execute "rake utils:git_push_if_needed"
    uploadToArtifactory {
        serverId = 'corp-dev'
        artifactPattern = "./artifacts/${product}_policies_${repo_version}.zip"
        repository = repo
        uploadPath = 'platform_buildservers/ncr_dfw_tcagent_build/policies/'
    }   
  }
}