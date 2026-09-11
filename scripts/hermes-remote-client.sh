#!/usr/bin/env bash
set -euo pipefail

SSH_CONFIG="/home/leo/.ssh/mcf-vps-control.conf"
SSH_TARGET="mcf-vps-control"
REMOTE_HERMES="/home/ubuntu/.local/bin/hermes"
SSH_COMMON=(
  -F "$SSH_CONFIG"
  -o BatchMode=yes
  -o ConnectTimeout=8
  -o ClearAllForwardings=yes
  -o ControlMaster=no
  -o ControlPath=none
)

fail() {
  printf '\nHermes Agent — %s\n' "$1" >&2
}

if [[ ! -f "$SSH_CONFIG" ]]; then
  fail "configuração SSH canônica não encontrada em $SSH_CONFIG"
  exit 2
fi

set +e
ssh "${SSH_COMMON[@]}" "$SSH_TARGET" "test -x $REMOTE_HERMES"
preflight_rc=$?
set -e

if (( preflight_rc == 255 )); then
  fail "não foi possível acessar a VPS pelo SSH canônico."
  exit 3
fi
if (( preflight_rc != 0 )); then
  fail "executável Hermes remoto indisponível em $REMOTE_HERMES."
  exit 4
fi

printf 'Hermes Agent — conectado à VPS.\n'
printf 'Fechar esta janela encerra somente o cliente remoto.\n\n'

set +e
ssh -tt "${SSH_COMMON[@]}" "$SSH_TARGET" "exec $REMOTE_HERMES chat"
chat_rc=$?
set -e

if (( chat_rc != 0 )); then
  fail "hermes chat encerrou com erro (código $chat_rc)."
  exit 5
fi
