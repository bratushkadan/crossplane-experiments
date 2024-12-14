resource "yandex_kubernetes_cluster" "this" {
  name        = "crossplane-experiments"
  description = "cluster for my experiments with Crossplane"

  network_id = yandex_vpc_network.this.id

  master {
    version = local.k8s_version
    zonal {
      zone      = local.default_zone
      subnet_id = yandex_vpc_subnet.this.id
    }

    security_group_ids = [yandex_vpc_security_group.this.id]

    maintenance_policy {
      auto_upgrade = false
    }
  }

  service_account_id      = yandex_iam_service_account.k8s-master.id
  node_service_account_id = yandex_iam_service_account.k8s-worker.id

  labels = {
    type        = "experimental"
    cluster_for = "crossplane"
  }

  release_channel         = "RAPID"
  network_policy_provider = "CALICO"
}

resource "yandex_kubernetes_node_group" "this" {
  cluster_id  = yandex_kubernetes_cluster.this.id
  name        = "crossplane-k8s-node-group"
  description = "node group for crossplane k8s cluster"
  version     = local.k8s_version

  labels = {}

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = [yandex_vpc_subnet.this.id]
      security_group_ids = [yandex_vpc_security_group.this.id]
    }

    resources {
      cores  = 2
      memory = 2
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    location {
      zone = local.default_zone
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "15:00"
      duration   = "3h"
    }

    maintenance_window {
      day        = "friday"
      start_time = "10:00"
      duration   = "4h30m"
    }
  }
}

resource "yandex_vpc_network" "this" {
  name = "crossplane-k8s-cluster"
}

resource "yandex_vpc_subnet" "this" {
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = local.default_zone
  network_id     = yandex_vpc_network.this.id
  name           = "crossplane-k8s-cluster-subnet-${local.default_zone}"
  description    = "subnet for crossplane k8s cluster in zone ${local.default_zone}"
}

resource "yandex_vpc_security_group" "this" {
  name        = "crossplane-k8s-sg"
  description = "security group for crossplane k8s cluster nets"
  network_id  = yandex_vpc_network.this.id
}

resource "yandex_vpc_security_group_rule" "ingress" {
  security_group_binding = yandex_vpc_security_group.this.id
  direction              = "ingress"
  description            = "ingress rule"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  protocol               = "ANY"
}

resource "yandex_vpc_security_group_rule" "egress" {
  security_group_binding = yandex_vpc_security_group.this.id
  direction              = "egress"
  description            = "egress rule"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  protocol               = "ANY"
}

resource "yandex_iam_service_account" "k8s-master" {
  name        = "crossplane-k8s-master"
  description = "service account to manage crossplane k8s masters"
}

resource "yandex_iam_service_account" "k8s-worker" {
  name        = "crossplane-k8s-worker"
  description = "service account to run crossplane k8s workers"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-master-cluster-agent" {
  folder_id = local.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-master.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "k8s-master-k8s-editor" {
  folder_id = local.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-master.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-worker-cr-puller" {
  folder_id = local.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-worker.id}"
}
