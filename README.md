## Setup nginx on arch linux


### Server block (example)
```
server {
	listen       80;
	server_name  localhost;

	location / {
	root   /var/www/test;
	index  index.php index.html index.htm;
	}
}
```

### PHP Implementation

Enable php-fpm service
```bash
sudo systemctl enable --now php-fpm.service
```

Add this to `/etc/nginx/sites-available/{site_name}.conf`
```
server {
	listen       80;
	server_name  localhost;

	location / {
	root   /var/www/test;
	index  index.php index.html index.htm;
	}

	location ~ \.php$ {
		fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
		fastcgi_index index.php;
		root /var/www/test;
		include fastcgi.conf;
	}
}
```

To enable the site:
```bash
sudo e2ensite {site_name}.conf
```

Restart nginx server:
```bash
sudo systemctl restart nginx.service
```