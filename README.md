# ptero-compose

ptero-composeは、PterodactylゲームサーバーパネルをDockerを使用して簡単にセットアップするためのリポジトリです。

## 前提条件

- Dockerがインストールされていること
- Docker Composeがインストールされていること
- Gitがインストールされていること

## インストール方法

以下の手順に従って、Pterodactylパネルをセットアップしてください。
```
git clone https://github.com/flll/ptero-compose
cd ptero-compose
chmod +x ./start
./start
docker compose up -d
docker exec -it pteroservice-panel-1 sh
php artisan migrate --seed --force
php artisan p:user:make
exit
curl panel.example.com
```

## 注意事項

- `panel.example.com`は、実際のドメインまたはホストファイルに設定したホスト名に置き換えてください。
- 環境によっては、`docker compose`コマンドが`docker-compose`となる場合があります。

## ライセンス

このリポジトリは[MITライセンス](LICENSE)の下で公開されています。

## 貢献

貢献を歓迎します。プルリクエストやイシューを通じて、リポジトリの改善にご協力ください。
