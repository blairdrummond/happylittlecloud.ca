#!/bin/sh

: "${GIT_REPO:?$(echo "not set, exiting."; exit 1)}"
: "${GIT_PATH:?$(echo "not set, exiting."; exit 1)}"

: "${DO_TOKEN:?$(echo "not set, exiting."; exit 1)}"

: "${SPACES_URL:?$(echo "not set, exiting."; exit 1)}"
: "${SPACES_BUCKET:?$(echo "not set, exiting."; exit 1)}"
: "${SPACES_KEY:?$(echo "not set, exiting."; exit 1)}"
: "${SPACES_SECRET:?$(echo "not set, exiting."; exit 1)}"

# Service meshes...
sleep 5

git clone -- $GIT_REPO repo
if ! [ -d "repo/$GIT_PATH" ]; then
    echo "$GIT_PATH does not exist, exiting." >&2
    exit 1
fi

mc diff repo/${GIT_PATH}/ do/$SPACES_BUCKET/

mc config host add do $SPACES_URL $SPACES_KEY $SPACES_SECRET || exit 1
mc mirror --fake --overwrite repo/${GIT_PATH}/ do/$SPACES_BUCKET/

#mc mirror 
CDN_ID=$(doctl compute cdn list -t access-token "$DO_TOKEN" -o text | grep "$SPACES_URL" | awk '{print $1}')
doctl compute cdn flush

grep '^!' /tmp/s3.diff > /tmp/s3.newer
