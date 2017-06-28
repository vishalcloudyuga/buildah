#!/usr/bin/env bats

load helpers

@test "from-by-id" {
  image=busybox

  # Pull down the image, if we have to.
  cid=$(buildah --debug=false from --pull --signature-policy ${TESTSDIR}/policy.json $image)
  [ $? -eq 0 ]
  [ $(wc -l <<< "$cid") -eq 1 ]
  buildah rm $cid

  # Get the image's ID.
  run buildah --debug=false images -q $image
  echo "$output"
  [ $status -eq 0 ]
  [ $(wc -l <<< "$output") -eq 1 ]
  iid="$output"

  # Use the image's ID to create a container.
  run buildah --debug=false from --pull --signature-policy ${TESTSDIR}/policy.json ${iid}
  echo "$output"
  [ $status -eq 0 ]
  [ $(wc -l <<< "$output") -eq 1 ]
  cid="$output"
  buildah rm $cid

  # Use a truncated form of the image's ID to create a container.
  run buildah --debug=false from --pull --signature-policy ${TESTSDIR}/policy.json ${iid:0:6}
  echo "$output"
  [ $status -eq 0 ]
  [ $(wc -l <<< "$output") -eq 1 ]
  cid="$output"
  buildah rm $cid

  buildah rmi $iid
}

@test "inspect-by-id" {
  image=busybox

  # Pull down the image, if we have to.
  cid=$(buildah --debug=false from --pull --signature-policy ${TESTSDIR}/policy.json $image)
  [ $? -eq 0 ]
  [ $(wc -l <<< "$cid") -eq 1 ]
  buildah rm $cid

  # Get the image's ID.
  run buildah --debug=false images -q $image
  echo "$output"
  [ $status -eq 0 ]
  [ $(wc -l <<< "$output") -eq 1 ]
  iid="$output"

  # Use the image's ID to inspect it.
  run buildah --debug=false inspect --type=image ${iid}
  echo "$output"
  [ $status -eq 0 ]

  # Use a truncated copy of the image's ID to inspect it.
  run buildah --debug=false inspect --type=image ${iid:0:6}
  echo "$output"
  [ $status -eq 0 ]

  buildah rmi $iid
}

@test "push-by-id" {
  for image in busybox kubernetes/pause ; do
    echo pulling/pushing image $image

    TARGET=${TESTDIR}/subdir-$(basename $image)
    mkdir -p $TARGET $TARGET-truncated

    # Pull down the image, if we have to.
    cid=$(buildah --debug=false from --pull --signature-policy ${TESTSDIR}/policy.json $image)
    [ $? -eq 0 ]
    [ $(wc -l <<< "$cid") -eq 1 ]
    buildah rm $cid

    # Get the image's ID.
    run buildah --debug=false images -q $IMAGE
    echo "$output"
    [ $status -eq 0 ]
    [ $(wc -l <<< "$output") -eq 1 ]
    iid="$output"

    # Use the image's ID to push it.
    run buildah push --signature-policy ${TESTSDIR}/policy.json $iid dir:$TARGET
    echo "$output"
    [ $status -eq 0 ]

    # Use a truncated form of the image's ID to push it.
    run buildah push --signature-policy ${TESTSDIR}/policy.json ${iid:0:6} dir:$TARGET-truncated
    echo "$output"
    [ $status -eq 0 ]

    buildah rmi $iid
  done
}