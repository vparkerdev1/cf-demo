
**Sources:** 

EC2 Module:
https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/v5.6.0/examples/complete/main.tf

VPC Module:
https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/examples/simple/outputs.tf

Security Group Module:
https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/rules.tf

ALB Module: 
https://github.com/terraform-aws-modules/terraform-aws-alb/tree/master

AWS AMI Terraform Data Source Documentation: 
- I used this to find the correct formatting for the ami filter and added it to my ec2.tf
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami

Terrafrom Resource Document for Route53 Zone Creation
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone


Error:

```
│ Error: Incorrect attribute value type
│
│   on .terraform/modules/alb/main.tf line 536, in resource "aws_lb_target_group_attachment" "this":
│  536:   target_id         = each.value.target_id
│     ├────────────────
│     │ each.value is object with 4 attributes
│
│ Inappropriate value for attribute "target_id": string required.
╵

```

Removed Code:

```
################################################################################
# Target Group Attachment
################################################################################

resource "aws_lb_target_group_attachment" "this" {
  for_each = { for k, v in var.target_groups : k => v if local.create && lookup(v, "create_attachment", true) }

  target_group_arn  = aws_lb_target_group.this[each.key].arn
  target_id         = each.value.target_id
  port              = try(each.value.target_type, null) == "lambda" ? null : try(each.value.port, var.default_port)
  availability_zone = try(each.value.availability_zone, null)

  depends_on = [aws_lambda_permission.this]
}
```

