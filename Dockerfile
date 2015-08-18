FROM centos:centos7

MAINTAINER NGINX Docker Maintainers "docker-maint@nginx.com"

RUN yum install -y wget

# Download certificate and key from the customer portal https://cs.nginx.com
# # and copy to the build context
RUN mkdir -p /etc/ssl/nginx
COPY etc/ssl/nginx/nginx-repo.crt /etc/ssl/nginx/nginx-repo.crt
COPY etc/ssl/nginx/nginx-repo.key /etc/ssl/nginx/nginx-repo.key

# Get other files required for installation
RUN wget -q -O /etc/ssl/nginx/CA.crt https://cs.nginx.com/static/files/CA.crt
RUN wget -q -O /etc/yum.repos.d/nginx-plus-7.repo https://cs.nginx.com/static/files/nginx-plus-7.repo

# Install NGINX Plus
RUN yum install -y nginx-plus
RUN yum install -y nginx-ha

# forward request logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# create cache folder and set permissions
CMD mkdir -p /var/spool/nginx/cache
CMD chown nginx /var/spool/nginx
CMD chown nginx /var/spool/nginx/cache

# copy /etc/nginx directory and /usr/share/nginx/html directory
COPY etc/nginx /etc/nginx
COPY usr/share/nginx/html/ /usr/share/nginx/html

EXPOSE 80 9000 443

CMD ["nginx", "-g", "daemon off;"]
