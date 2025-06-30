openssl rand -base64 756 > ./keyfile

mongod -f m1.conf
mongod -f m2.conf
mongod -f m3.conf