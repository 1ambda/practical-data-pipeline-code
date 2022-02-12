locals {
  environment_common = "common"
  environment_development = "development"
  environment_production = "production"

  region_seoul = "ap-northeast-2"

  team_data = "data"
}

locals {
  network_range_ssh_whitelist = "0.0.0.0/0"
}

locals {
  // https://docs.aws.amazon.com/ko_kr/emr/latest/ManagementGuide/emr-web-interfaces.html
  // @formatter:off
  emr_web_ports_master = [
    {
      port = 8088
      name = "YARN Resource Manager"
    },
    {
      port = 8042
      name = "YARN Node Manager"
    },
    {
      port = 50470
      name = "HDFS Name Node less 6.x"
    },
    {
      port = 50070
      name = "HDFS Name Node"
    },
    {
      port = 9871
      name = "HDFS Name Node 6.x"
    },
    {
      port = 50475
      name = "HDFS Data Node less 6.x"
    },
    {
      port = 50075
      name = "HDFS Data Node"
    },
    {
      port = 9865
      name = "HDFS Data Node 6.x"
    },

    {
      port = 18080
      name = "Spark UI"
    },
    {
      port = 20888
      name = "Spark Streaming UI"
    },
    {
      port = 19888
      name = "Spark Log"
    },

    {
      port = 80
      name = "Ganglia"
    },
    {
      port = 10000
      name = "Hive Server"
    },
    {
      port = 9083
      name = "Hive Metastore"
    },
    {
      port = 8889
      name = "Presto UI"
    },

    {
      port = 8890
      name = "Zeppelin"
    },
    {
      port = 8888
      name = "Hue"
    },
    {
      port = 16010
      name = "HBase UI"
    },
    {
      port = 9443
      name = "Jupyter UI"
    },
    {
      port = 41001
      name = "Test"
    },
  ]

  emr_web_ports_slave = [
    {
      port = 8042
      name = "YARN NM"
    },
    {
      port = 50075
      name = "HDFS DN"
    },
  ]
  // @formatter:on
}