data "template_file" "userdata" {
  #count = var.environment_linux ? 1 : 0
  #template = file("${path.module}/userdata_linux.tpl")
  template = "${var.environment_linux == "true" ? file("${path.module}/userdata_linux.tpl") : file("${path.module}/userdata_win.tpl")}"

  vars = {
    tf_cluster_name = aws_ecs_cluster.ecs.name
    tf_efs_id       = "${var.environment_linux == "true" ? aws_efs_file_system.ecs.id : null"
    #tf_efs_id       = aws_efs_file_system.ecs.id
    userdata_extra  = var.userdata
  }
}

# data "template_file" "userdata" {
#   count = var.environment_windows ? 1 : 0
#   template = file("${path.module}/userdata_win.tpl")

#   vars = {
#     tf_cluster_name = aws_ecs_cluster.ecs.name
#     userdata_extra  = var.userdata
#   }
# }

resource "aws_launch_template" "ecs" {
  count = var.environment_linux ? 1 : 0
  name_prefix   = "ecs-${var.name}-"
  image_id      = data.aws_ami.amzn.image_id
  instance_type = var.instance_type_1

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.instance_volume_size_root
    }
  }

  block_device_mappings {
    device_name = "/dev/xvdcz"

    ebs {
      volume_size = var.instance_volume_size
    }
  }

  vpc_security_group_ids = concat(list(aws_security_group.ecs_nodes.id), var.security_group_ids)

  user_data = base64encode(data.template_file.userdata.rendered)

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_launch_template" "ecs" {
  count = var.environment_windows ? 1 : 0
  name_prefix   = "ecs-${var.name}-"
  image_id      = data.aws_ami.amzn.image_id
  instance_type = var.instance_type_1

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.instance_volume_size_root
    }
  }

  vpc_security_group_ids = concat(list(aws_security_group.ecs_nodes.id), var.security_group_ids)

  user_data = base64encode(data.template_file.userdata.rendered)

  lifecycle {
    create_before_destroy = true
  }
}
