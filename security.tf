// ==========================
// == SECURITY GROUP RULES ==
// ==========================

// == HTTP ==

resource "aws_security_group_rule" "allow_http_inbound" {
  type        = "ingress"
  from_port   = "${var.http_port}"
  to_port     = "${var.http_port}"
  protocol    = "tcp"
  cidr_blocks = ["${var.allowed_inbound_cidr_blocks}"]

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

// == RPC ==

resource "aws_security_group_rule" "allow_rpc_inbound" {
  type        = "ingress"
  from_port   = "${var.rpc_port}"
  to_port     = "${var.rpc_port}"
  protocol    = "tcp"
  cidr_blocks = ["${var.allowed_inbound_cidr_blocks}"]

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

// == TCP ==

resource "aws_security_group_rule" "allow_serf_tcp_inbound" {
  type        = "ingress"
  from_port   = "${var.serf_port}"
  to_port     = "${var.serf_port}"
  protocol    = "tcp"
  cidr_blocks = ["${var.allowed_inbound_cidr_blocks}"]

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

// == UDP ==

resource "aws_security_group_rule" "allow_serf_udp_inbound" {
  type        = "ingress"
  from_port   = "${var.serf_port}"
  to_port     = "${var.serf_port}"
  protocol    = "udp"
  cidr_blocks = ["${var.allowed_inbound_cidr_blocks}"]

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

// == SSH ==

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type        = "ingress"
  from_port   = "${var.ssh_port}"
  to_port     = "${var.ssh_port}"
  protocol    = "tcp"
  cidr_blocks = ["${var.allowed_ssh_cidr_blocks}"]

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

// == OUTBOUND ==

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.lc_security_group.id}"
}

// =====================
// == SECURITY GROUPS ==
// =====================

resource "aws_security_group" "lc_security_group" {
  name_prefix = "${var.cluster_name}"
  description = "Security group for the ${var.cluster_name} launch configuration"
  // if this is empty, does it set it up on the parent vpc
  vpc_id      = "${var.vpc_id}"
}
