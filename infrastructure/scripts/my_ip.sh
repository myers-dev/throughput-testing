#!/usr/bin/env bash
function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function my_ip() {
  ip=$(curl -s https://api.my-ip.io/ip.json | jq "{ my_ip: .ip }")
  echo $ip
}

my_ip