```bash
packer validate packer.json

# Use real values

export ACCESS_KEY_ID="MY ACCESS KEY ID"

export SECRET_ACCESS_KEY="MY SECRET ACCESS KEY"

packer validate \
    packer.json

packer build \
    -var aws_access_key=$ACCESS_KEY_ID \
    -var aws_secret_key=$SECRET_ACCESS_KEY \
    packer.json
```

TODO
----

* Open ports