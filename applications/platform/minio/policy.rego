package httpapi.authz

import input

default allow = false

rl_permissions := {
    "user": [
        {"action": "s3:CreateBucket"},
        {"action": "s3:DeleteBucket"},
        {"action": "s3:DeleteObject"},
        {"action": "s3:GetObject"},
        {"action": "s3:ListAllMyBuckets"},
        {"action": "s3:GetBucketObjectLockConfiguration"},
        {"action": "s3:ListBucket"},
        {"action": "s3:PutObject"},
    ]
}

##
## PRIVATE BUCKETS
##

# Allow access from OIDC
allow {
    # input.claims.preferred_username == "blairdrummond"
    # profiles[input.bucket][_] == ""
    permissions := rl_permissions.user
    p := permissions[_]
    p == {"action": input.action}
}

