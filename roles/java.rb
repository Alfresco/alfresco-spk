name "java"
description "Baseline configuration for Alfresco Repository"
 
run_list(
  "recipe[alfresco::setup_java_tools]"
)

default_attributes(
  "java" => {
    "default" => true,
    "jdk_version" => '7',
    "install_flavor" => 'oracle',
    "oracle" => {
      "accept_oracle_download_terms" => true
    }
  }
)
