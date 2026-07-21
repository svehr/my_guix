### How-To

#### Update

```sh
guix pull
guix upgrade
```

Note:
- [Reconfigure](#reconfigure) after updating
- `guix upgrade` is an alias for `guix package -u`

#### Check news

```sh
guix pull --news
```

#### Reconfigure

```sh
sudo mount /boot
guix-system.sh reconfigure
guix-home-reconfigure.sh
```

To avoid connecting to the internet (if possible)
```sh
guix-home-reconfigure.sh --no-substitutes
```