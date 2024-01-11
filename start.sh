#!/bin/bash -eu
cd "$(dirname "$0")"

info(){
  echo -e "[\e[34mINFO\e[0m]" "$@"
}
fatal(){
  echo -e "[\e[31mERROR\e[0m]" "$@" >&2
  exit 1
}

required_commands=(
  "docker"
  "sudo"
)

missing_commands=""
for cmd in "${required_commands[@]}"; do
  hash "${cmd}" 2>/dev/null || missing_commands+="${cmd} "
done
if [[ -n ${missing_commands} ]]; then
  info "以下のコマンドが不足しています:" >&2
  info "\e[31m${missing_commands}\e[0m"
  info "このスクリプトを実行するには上記のコマンドが必要です" >&2 &
  exit 127
fi




change_domain_name(){
  if [ -f .env ]; then
    . .env
    info "ドメイン名が${SERVER_NAME}になっています。変更しますか？ [y/N]"
    read answer
    if [[ "$answer" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      while true; do
        info "panelのドメイン名を入力してください。例: panel.lll.fish、localhost、panel.example.com"
        info "http:// は入力しないでください"
        read domain
        if echo "$domain" | grep -qE '^[a-zA-Z0-9.-]+$'; then
          sed -i "s>^SERVER_NAME=.*>SERVER_NAME=$domain>" .env
          info "SERVER_NAMEを${domain} に変更しました。"
          break
        else
          info "ドメイン名に不適切な文字が含まれています。もう一度入力してください。"
        fi
      done
    else
      info "ドメイン名の変更はスキップされました。"
    fi
  fi
}


generate_env_file(){
  read -p ".envを生成しますか? [y/N] " key_response
  if [[ "$key_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    info "鍵生成用のコンテナをビルドします"
    [ -f .env ] || { cp .env.example .env; env_created=true; }
    docker build \
           --target build \
           -t keygen_stage \
           -f panel.Dockerfile .
    docker run \
           --rm -it \
           --name keygen_container \
           --mount type=bind,source=$(pwd)/.env,target=/var/www/pterodactyl/.env \
           keygen_stage \
             || { fatal "鍵生成に失敗しました" & [ $env_created ] && rm .env; }
    docker kill keygen_container > /dev/null 2>&1 ||:
    docker rmi  keygen_stage > /dev/null 2>&1 ||:

    sed -i 's>CACHE_DRIVER=file>CACHE_DRIVER=redis>' .env
    if ! grep -q "HASHIDS_SALT=." .env; then
      RANDOM_SALT=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
      sed -i "s>HASHIDS_SALT=>HASHIDS_SALT=$RANDOM_SALT>" .env
    fi
    info ".env が生成されました"
    info "docker compose up -d を実行してください"
    # 生成されたら初期設定としてドメインを変更します
    change_domain_name
  fi
}




change_domain_name
generate_env_file

sudo sysctl vm.overcommit_memory=1

  info "nginx-default.conf を生成します"
  source .env
  export SERVER_NAME
  envsubst '$$SERVER_NAME' < nginx-default.conf.example > nginx-default.conf

