FROM ubuntu:18.04

WORKDIR /tmp
COPY playbooks /tmp/playbooks/
COPY hosts /tmp/hosts
COPY ansible.cfg /tmp/ansible.cfg

RUN apt update && apt-get install -y ansible

RUN ansible-playbook playbooks/ubuntu.yml
RUN ansible-galaxy install fubarhouse.rust && ansible-playbook playbooks/rust.yml
RUN ansible-playbook playbooks/devtools.yml
RUN ansible-playbook playbooks/llvm.yml
RUN ansible-playbook playbooks/gbits.yml
RUN ansible-playbook playbooks/bcc.yml
RUN ansible-playbook playbooks/dpdk.yml
