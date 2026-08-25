### Install Docker Engine on RHEL

#### Uninstall old versions

```bash
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc
```

#### Install using the rpm repository

```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
```

##### Install Docker Engine

```bash
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker
```

#### Uninstall Docker Engine

```bash
sudo dnf remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

#### 镜像加速器

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://docker.xuanyuan.me",
    "https://docker.1ms.run"
  ]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

#### 证书申请与续签

```bash
certbot certonly  -d *.runoob.com --manual --preferred-challenges dns --server https://acme-v02.api.letsencrypt.org/directory

certbot certonly --force-renewal --manual -d '*.runoob.com' --preferred-challenges dns --server https://acme-v02.api.letsencrypt.org/directory
```
