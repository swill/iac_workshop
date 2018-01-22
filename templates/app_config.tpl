#cloud-config

coreos:
  units:
    - name: "iac-workshop.service"
      command: "start"
      content: |
        [Unit]
        Description=iac-workshop
        After=network-online.target
        Requires=network-online.target
        After=docker.service
        Requires=docker.service

        [Service]
        TimeoutStartSec=0
        ExecStart=/usr/bin/docker run -e "APP_PORT=${app_port}" -e "APP_INSTANCE=${instance_id}" -e "APP_CLOUD=${cloud_label}" -p ${app_port}:${app_port} wstevens/iac-workshop