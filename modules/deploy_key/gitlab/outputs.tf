/**
 * File: /outputs.tf
 * Project: gitlab
 * File Created: 16-04-2022 01:29:38
 * Author: Clay Risser
 * -----
 * Last Modified: 16-04-2022 01:32:03
 * Modified By: Clay Risser
 * -----
 * Risser Labs LLC (c) Copyright 2022
 */

output "public_key" {
  value = tls_private_key.ssh.public_key_openssh
}
