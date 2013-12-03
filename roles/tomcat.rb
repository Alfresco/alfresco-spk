name "tomcat"
description "Baseline configuration for applications that need to be installed on Tomcat"

default_attributes(
  "tomcat" => {
    "base_version" => 7,
    "user" => "tomcat7",
    "group" => "tomcat7"
  }
)