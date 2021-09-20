# acrobox/restic

Dockerized [restic](https://restic.net) client for [Acrobox](https://acrobox.io) and lovers.

```sh
$ docker build -t acrobox/restic .
$ docker volume create restic-cache
$ docker run --rm -v restic-cache:/cache alpine:latest chown -R $(id -u):$(id -g) /cache
$ docker run --rm -i -t -u $(id -u):$(id -g) -e RESTIC_REPOSITORY="" -e RESTIC_PASSWORD="" -v /acrobox:/data -v restic-cache:/cache acrobox/restic init
```
