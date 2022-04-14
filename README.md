# eks

> terraform deployment for eks clusters

## Usage

The terraform will be applied using a GitHub action when it is
merged into the `main` branch.

| command           | description                                           |
| ----------------- | ----------------------------------------------------- |
| `make apply`      | applies terraform infrastructure                      |
| `make destroy`    | destroys terraform infrastructure                     |
| `make format`     | formats terraform files                               |
| `make init`       | initializes terraform                                 |
| `make kubeconfig` | authenticate local environment with the eks cluster   |
| `make lint`       | lints terraform files                                 |
| `make plan`       | creates terraform plan                                |
| `make refresh`    | refreshes terraform state to match physical resources |

## Setup Kubeconfig

```sh
aws eks update-kubeconfig --region us-west-2 --name eks-main
```

## Dependencies

If you are using Windows, please use the
[Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install)
with [Debian](https://www.microsoft.com/en-in/p/debian/9msvkqc78pk6).

#### [Terraform](https://www.terraform.io/downloads)

#### [AWS CLI](https://aws.amazon.com/cli)

You can install the aws cli on OSX and Linux using the
following command, assuming you have pip installed and setup.

```sh
sudo pip install awscli
```

Make sure you configure the aws cli after it is installed.

```sh
aws configure
```

#### [GNU Make](https://www.gnu.org/software/make)

GNU Make is recommended over other versions of make. If you are
on OSX it can be installed using the following command.

```sh
brew install gmake
```
