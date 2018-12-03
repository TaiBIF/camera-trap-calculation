camera-trap-calculation
=======================

## 目的

將 R 的計算程式轉成 Python，並且使用 Flask 製作成 RESTful API。


## 檔案位置
- R 程式碼放在 `./from-mai` 資料夾。
- Python 計算程式放在 `./flaskr/scripts/NOEveryThing`
- Flask API 為 ./flaskr/app.py

採用 Flask 官方建議的 [Project Layout](http://flask.pocoo.org/docs/1.0/tutorial/layout/)

## Deploy

部署的工具
- [Gunicorn](https://gunicorn.org/) - Python WSGI HTTP Server for UNIX

- [Supervisor](http://supervisord.org/) -  A Process Control System

原因有
- 配置簡單。
- 輕便佔的容量不大。
- 與 Python 相容性佳。
- 使用人數多，有問題比較好解決。

## 配置文件
位置在 `/etc/supervisor.conf`

```
[program:flask]
command=gunicorn -w4 -b10.0.10.31:80 app:app     # 執行 gunicorn 命令
startsecs=0-                                     # 啟動程式多少秒之後判斷狀態
stopwaitsecs=0                                   # 程式等待時間，若超過這個秒數則自動取消
autostart=true                                   # 自動開啟
autorestart=true                                 # 程式異常退出後是否重啟
stdout_logfile=/tmp/gunicorn.log                 # log 檔案位置
stderr_logfile=/tmp/gunicorn.err                 # error log 檔案位置
```

詳細的配置可以參考 [Supervisor Docs](http://supervisord.org/configuration.html)。


## 常用指令

```shell
$ supervisord -c /etc/supervisor.conf    # 使用 supervisor.conf 的配置
$ ps aux | grep supervisord              # 查看目前執行的排程
$ supervisorctl status                   # 查看目前狀態 
$ supervisorctl stop flask               # 停止配置文件上定義的程序
$ supervisorctl start flask              # 開啟止配置文件上定義的程序
$ supervisorctl restart flask            # 重啟配置文件上定義的程序
$ supervisorctl update                   # 重新更新
```

## 參考文獻
- [Deploy flask app with nginx using gunicorn and supervisor](https://medium.com/ymedialabs-innovation/deploy-flask-app-with-nginx-using-gunicorn-and-supervisor-d7a93aa07c18?fbclid=IwAR1yzITlkRKxjYIWDI_wyOk2NXzRL83Kvf-Gcc0B4fF51DmxG8QJN7xKD1g)

- [Gunicorn](https://gunicorn.org/) - Python WSGI HTTP Server for UNIX.

- [Supervisor](http://supervisord.org/) -  A Process Control System.

- [Flask](http://flask.pocoo.org/) - A microframework for Python based on Werkzeug, Jinja 2 and good intentions.