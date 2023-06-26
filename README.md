# rock8s-cluster

> terraform deployment for rock8s clusters

## Usage

The terraform will be applied using a GitHub action when it is
merged into the `main` branch.

| command                | description                                           |
| ---------------------- | ----------------------------------------------------- |
| `make allow-destroy`   | allow resource to be destroyed                        |
| `make apply`           | applies terraform infrastructure                      |
| `make clean`           | clean repo                                            |
| `make destroy`         | destroys terraform infrastructure                     |
| `make format`          | formats terraform files                               |
| `make init`            | initializes terraform                                 |
| `make kubeconfig`      | authenticate local environment with the kube cluster  |
| `make lint`            | lints terraform files                                 |
| `make plan`            | creates terraform plan                                |
| `make prevent-destroy` | prevent resources from being destroyed                |
| `make purge`           | purge repo                                            |
| `make refresh`         | refreshes terraform state to match physical resources |

```sh
make apply
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

GNU Make 4 is recommended over other versions of make. If you are
on OSX it can be installed using the following command.

```sh
brew install remake
```
