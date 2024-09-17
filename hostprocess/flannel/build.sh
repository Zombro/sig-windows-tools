#!/bin/bash

# https://devhints.io/bash
# while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
#   -f | --flannelVersion )
#     shift; flannelVersion="$1"
#     ;;
#   -p | --proxyVersion )
#     shift; proxyVersion="$1"
#     ;;
#   -r | --repository )
#     shift; repository="$1"
#     ;;
#   -a | --all )
#     shift; all="1"
#     ;;
# esac; shift; done
# if [[ "$1" == '--' ]]; then shift; fi

# repository=${repository:-"sigwindowstools"}

# hardcoded here for convenience
# see images at https://hub.docker.com/repositories/zombro
repository=zombro
flannelVersion=v0.24.2
# flannelVersion=v0.15.1
proxyVersion=v1.28.2 # was 1.28.6

docker buildx create --name img-builder --use --platform windows/amd64
trap 'docker buildx rm img-builder' EXIT

if [[ -n "$flannelVersion" || "$all" == "1" ]] ; then
  # set default
  flannelVersion=${flannelVersion:-"v0.24.0"}
  pushd flanneld
  docker buildx build --provenance=false --sbom=false --platform windows/amd64 --output=type=registry --pull --build-arg=flannelVersion=$flannelVersion -f Dockerfile -t $repository/flannel:$flannelVersion-hostprocess .
  popd
fi

if [[ -n "$proxyVersion" || "$all" == "1" ]] ; then
  # set default
  proxyVersion=${proxyVersion:-"v1.28.2"}
  pushd kube-proxy
  docker buildx build --provenance=false --sbom=false --platform windows/amd64 --output=type=registry --pull --build-arg=k8sVersion=$proxyVersion -f Dockerfile -t $repository/kube-proxy:$proxyVersion-flannel-hostprocess .
  popd
fi
