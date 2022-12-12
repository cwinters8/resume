# resume

This repo contains my current [resume](./resume.md) in markdown format, along with its CSS styling and a github actions workflow for building html and pdf artifacts and deploying them to github pages.

## building artifacts locally

### prerequisites

#### [pandoc](https://pandoc.org)

used for converting md to html

```sh
brew install pandoc
```

#### [chromium](https://www.chromium.org/Home/)

used for generating pdf from html

```sh
brew install --cask chromium
```

### build

The build script will place built artifacts in a directory named `output`, which will be created if it does not exist.

```sh
./build.sh
```
