## Quick Reference


### Image Commands

|Command|Description|
|---|---|
|`docker build -t name:tag .`|Build image from current directory|
|`docker pull image:tag`|Pull image from registry|
|`docker push image:tag`|Push image to registry|
|`docker images`|List local images|
|`docker rmi image:tag`|Remove image|
|`docker image prune`|Remove dangling images|

### Container Commands

|Command|Description|
|---|---|
|`docker run -d --name n image`|Run container in background|
|`docker run -it image bash`|Run interactively|
|`docker ps`|List running containers|
|`docker ps -a`|List all containers|
|`docker stop name`|Stop container (SIGTERM)|
|`docker rm name`|Remove stopped container|
|`docker logs -f name`|Stream logs|
|`docker exec -it name bash`|Shell into container|
|`docker inspect name`|Full container metadata|

### Volume Commands

|Command|Description|
|---|---|
|`docker volume create vol`|Create named volume|
|`docker volume ls`|List volumes|
|`docker volume rm vol`|Remove volume|
|`docker volume prune`|Remove unused volumes|

### Network Commands

|Command|Description|
|---|---|
|`docker network create net`|Create network|
|`docker network ls`|List networks|
|`docker network connect net ctr`|Connect container to network|
|`docker network inspect net`|Inspect network|

### System Commands

|Command|Description|
|---|---|
|`docker system df`|Disk usage|
|`docker system prune`|Clean unused resources|
|`docker system prune -a`|Clean all unused images too|
|`docker info`|Docker daemon info|
|`docker version`|Client and daemon versions|

---

