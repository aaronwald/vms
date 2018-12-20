FROM ubuntu:18.04

WORKDIR /tmp
COPY playbooks /tmp/playbooks/
COPY hosts /tmp/hosts
COPY ansible.cfg /tmp/ansible.cfg

RUN apt update
RUN apt-get install -y ansible

RUN ansible-playbook playbooks/ubuntu.yml
RUN ansible-playbook playbooks/devtools.yml
RUN ansible-playbook playbooks/llvm.yml
RUN ansible-playbook playbooks/gbits.yml
RUN ansible-playbook playbooks/bcc.yml
