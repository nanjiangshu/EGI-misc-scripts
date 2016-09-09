#cloud-config

users:
  - name: nanjiang
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock-passwd: true
    ssh-import-id: nanjiang
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6xZlwFv9yWTBxQPHQcwUMETO8JO+qY55rQO8LPs6ncqidUX2BBjd92KHTOyLLZMG3fyWDKs/Tjm9mPHs+xEMBPpaQ2/xjy745m+cm1tEAiOo/hL4lemKtLuVO1aOZlN5eY2MeggRPUh1HlNBeAbOiDa8DQ0jPPlKrV//9ULXFNHeGTDYRrbBsWpVd5IPIW2dzfYnJF5j+xdQKr5Hvmvk+TmzcEIVOlkkRvX/+DBz405gVVrbO4aH4a9G+/9OuZauCkQNg6hXwBv+XetpXOoLKK9eyGrGTRLaeE3NqBgonmhquFM4wIh0JiR3nTD8FW/R8hCQlQQ0v5Nkd66IX3XNd nanjiang.shu@dbb.su.se
