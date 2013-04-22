### ROTATE! Server

0a) sudo npm install
0b) sudo npm install supervisor -g
0c) sudo npm install coffee-script -g

1) (sudo) mongod run --config /usr/local/etc/mongod.conf --rest

2) supervisor server.coffee

3) nohup supervisor server.coffee > output.log &