data "template_file" "bastion_template_cloudwatch" {
  template = file("${path.root}/_template/template.cloudwatch.sh")

  vars = {
    user                       = "ec2-user"
    installer                  = "yum"
    agent_version              = "1.2.2"
  }
}


data "template_cloudinit_config" "bastion_user_data" {
  gzip          = false
  base64_encode = true

  # install patches for Amazon Linux
  part {
    content_type = "text/x-shellscript"

    content = <<EOF
#!/bin/bash
yum update -y
EOF
  }

  # https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/amazon-linux-install.html
  # install correto8
  part {
    content_type = "text/x-shellscript"

    content = <<EOF
#!/bin/bash
amazon-linux-extras enable corretto8
yum install -y java-1.8.0-amazon-corretto-devel
EOF
  }

  # install agent for cloudwatch custom metric
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.bastion_template_cloudwatch.rendered
  }
}
