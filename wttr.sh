#!/usr/bin/env bash
# If you source this file, it will set WTTR_PARAMS as well as show weather.

# WTTR_PARAMS is space-separated URL parameters, many of which are single characters that can be
# lumped together. For example, "F q m" behaves the same as "Fqm".
WTTR_PARAMS=${WTTR_PARAMS:-}

if [[ -z "$WTTR_PARAMS" ]]; then
  # Form localized URL parameters for curl
  if [[ -t 1 ]] && [[ "$(tput cols)" -lt 125 ]]; then
      WTTR_PARAMS+='n'
  fi 2> /dev/null
  for _token in $( locale LC_MEASUREMENT ); do
    case $_token in
      1) WTTR_PARAMS+='m' ;;
      2) WTTR_PARAMS+='u' ;;
    esac
  done 2> /dev/null
  unset _token
  export WTTR_PARAMS
fi

wttr() {
  local location="${1// /+}"
  command shift
  local -a curl_args=(-fGsS --compressed -H "Accept-Language: ${LANG%_*}")
  local p
  for p in $WTTR_PARAMS "$@"; do
    curl_args+=(--data-urlencode "$p")
  done
  curl "${curl_args[@]}" --max-time 20 "https://wttr.in/${location}"
}

wttr "$@"
