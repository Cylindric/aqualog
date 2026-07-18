```bash
poetry sync
eval $(poetry env activate)
ansible-galaxy collection install digitalocean.cloud

cp vars.example.yml vars.live.yml
# fill in the various tokens needed. You won't be able to put in the aqualog_oauth_client_id until after this has been run once, and you've configured Authentik.

ansible-playbook -i inventory/digitalocean.yml --extra-vars "@vars.live.yml" playbooks/aquahub.yml
```
